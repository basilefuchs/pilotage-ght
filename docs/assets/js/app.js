(() => {
  const REPO = window.__REPO__;
  const RAW_BASE = `https://raw.githubusercontent.com/${REPO.owner}/${REPO.name}/${REPO.branch}/`;

  const $search = document.getElementById("search");
  const $category = document.getElementById("category");
  const $onlyR = document.getElementById("only-r");
  const $results = document.getElementById("results");
  const $detail = document.getElementById("detail");
  const $count = document.getElementById("count");

  let DATA = null;
  let INDEX = null;
  let BY_ID = new Map();
  let CURRENT_ID = null;

  const fileCache = new Map();
  async function fetchText(relPath) {
    if (fileCache.has(relPath)) return fileCache.get(relPath);
    const p = fetch(RAW_BASE + relPath).then(r => {
      if (!r.ok) throw new Error(`HTTP ${r.status} sur ${relPath}`);
      return r.text();
    });
    fileCache.set(relPath, p);
    return p;
  }

  function buildLunr(entries) {
    return lunr(function () {
      if (lunr.fr) this.use(lunr.fr);
      this.ref("id");
      this.field("title", { boost: 5 });
      this.field("category_label", { boost: 2 });
      this.field("text");
      // Allow trailing wildcard matching by default
      this.metadataWhitelist = [];
      entries.forEach(e => this.add({
        id: e.id,
        title: e.title,
        category_label: e.category_label,
        text: e.text,
      }));
    });
  }

  function populateCategories(entries) {
    const cats = new Map();
    entries.forEach(e => cats.set(e.category, e.category_label));
    [...cats.entries()].sort().forEach(([key, label]) => {
      const opt = document.createElement("option");
      opt.value = key;
      opt.textContent = label;
      $category.appendChild(opt);
    });
  }

  function currentFilter(list) {
    const cat = $category.value;
    const onlyR = $onlyR.checked;
    return list.filter(e =>
      (!cat || e.category === cat) &&
      (!onlyR || e.path_r)
    );
  }

  function search() {
    const q = $search.value.trim();
    let list;
    if (!q) {
      list = DATA.entries;
    } else {
      let hits;
      try {
        // Match prefixes too: append * to each token that doesn't already include operators
        const cleaned = q.replace(/[:^~+*\-]/g, " ").trim();
        const tokens = cleaned.split(/\s+/).filter(Boolean);
        const lunrQ = tokens.map(t => `${t}* ${t}^2`).join(" ");
        hits = INDEX.search(lunrQ);
      } catch (e) {
        hits = [];
      }
      list = hits.map(h => BY_ID.get(h.ref)).filter(Boolean);
    }
    list = currentFilter(list);
    renderResults(list);
  }

  function renderResults(list) {
    $count.textContent = `${list.length} résultat${list.length > 1 ? "s" : ""}`;
    if (!list.length) {
      $results.innerHTML = `<div class="loading">Aucun résultat.</div>`;
      return;
    }
    const frag = document.createDocumentFragment();
    list.slice(0, 200).forEach(e => {
      const div = document.createElement("div");
      div.className = "result" + (e.id === CURRENT_ID ? " active" : "");
      div.dataset.id = e.id;
      div.innerHTML = `
        <div class="result-title"></div>
        <div class="result-meta">
          <span class="cat"></span>
          ${e.path_r ? '<span class="badge-r">R</span>' : ""}
          ${e.verified ? '<span class="badge-verified">✓</span>' : ""}
        </div>
        <div class="result-excerpt"></div>
      `;
      div.querySelector(".result-title").textContent = e.title;
      div.querySelector(".cat").textContent = e.category_label;
      div.querySelector(".result-excerpt").textContent = e.excerpt;
      if (e.verified) {
        div.querySelector(".badge-verified").title =
          `Vérifié le ${e.verified.date}` + (e.verified.by ? ` par ${e.verified.by}` : "");
      }
      div.addEventListener("click", () => selectEntry(e.id));
      frag.appendChild(div);
    });
    $results.replaceChildren(frag);
  }

  async function selectEntry(id, tab) {
    const entry = BY_ID.get(id);
    if (!entry) return;
    CURRENT_ID = id;
    const wantTab = (tab === "r" && entry.path_r) ? "r" : "md";
    updateHash(id, wantTab);
    document.querySelectorAll(".result").forEach(el =>
      el.classList.toggle("active", el.dataset.id === id)
    );
    renderDetail(entry, wantTab);
  }

  function renderDetail(entry, tab) {
    const hasR = !!entry.path_r;
    const tabsHtml = `
      <div class="tabs">
        <button data-tab="md" class="${tab === "md" ? "active" : ""}">Fiche</button>
        ${hasR ? `<button data-tab="r" class="${tab === "r" ? "active" : ""}">Script R</button>` : ""}
        <a class="gh-link"
           href="https://github.com/${REPO.owner}/${REPO.name}/blob/${REPO.branch}/${entry.path_md}"
           target="_blank" rel="noopener">Ouvrir sur GitHub ↗</a>
      </div>
      <div class="tab-content"><div class="loading">Chargement…</div></div>
    `;
    $detail.innerHTML = tabsHtml;
    $detail.querySelectorAll(".tabs button").forEach(b => {
      b.addEventListener("click", () => selectEntry(entry.id, b.dataset.tab));
    });
    const $content = $detail.querySelector(".tab-content");

    if (tab === "md") {
      // text already in index — no fetch needed
      try {
        $content.innerHTML = marked.parse(entry.text);
        $content.querySelectorAll("pre code").forEach(b => hljs.highlightElement(b));
      } catch (e) {
        $content.innerHTML = `<div class="error">Erreur de rendu : ${e.message}</div>`;
      }
    } else {
      fetchText(entry.path_r).then(src => {
        const pre = document.createElement("pre");
        const code = document.createElement("code");
        code.className = "language-r";
        code.textContent = src;
        pre.appendChild(code);
        $content.replaceChildren(pre);
        hljs.highlightElement(code);
      }).catch(err => {
        $content.innerHTML = `<div class="error">Impossible de charger le script R : ${err.message}</div>`;
      });
    }

    $detail.scrollTop = 0;
  }

  function updateHash(id, tab) {
    const params = new URLSearchParams();
    params.set("id", id);
    if (tab && tab !== "md") params.set("tab", tab);
    const next = "#" + params.toString();
    if (location.hash !== next) history.replaceState(null, "", next);
  }

  function readHash() {
    if (!location.hash || location.hash.length < 2) return null;
    const params = new URLSearchParams(location.hash.slice(1));
    const id = params.get("id");
    if (!id) return null;
    return { id, tab: params.get("tab") || "md" };
  }

  async function main() {
    try {
      const resp = await fetch("data/index.json");
      if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
      DATA = await resp.json();
    } catch (e) {
      $results.innerHTML = `<div class="error">Erreur de chargement de l'index : ${e.message}</div>`;
      return;
    }
    DATA.entries.forEach(e => BY_ID.set(e.id, e));
    populateCategories(DATA.entries);
    INDEX = buildLunr(DATA.entries);

    $search.addEventListener("input", search);
    $category.addEventListener("change", search);
    $onlyR.addEventListener("change", search);
    window.addEventListener("hashchange", () => {
      const h = readHash();
      if (h && h.id !== CURRENT_ID) selectEntry(h.id, h.tab);
    });

    search();

    const h = readHash();
    if (h) selectEntry(h.id, h.tab);
  }

  main();
})();
