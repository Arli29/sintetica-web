<%@ page contentType="text/html; charset=UTF-8" language="java" isELIgnored="true" %>
<%
    String ctx = request.getContextPath(); // ej: /sintetica-login
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Rompecanchas · Jugar y ganar</title>

  <!-- Si ya tienes un CSS para esto -->
  <link rel="stylesheet" href="<%= ctx %>/assets/css/rompecabezas.css" />
</head>
<body>
  <div class="wrap">
    <h1>Rompecanchas</h1>
    <p class="lead">
      Arma la imagen deslizando pieza por pieza hacia el espacio vacío.
      Si lo completas a tiempo, ¡ganas un descuento para tus reservas!
    </p>

    <section class="toolbar">
      <div class="group">
        <label for="size">Tamaño</label>
        <select id="size">
          <option value="3">3 × 3</option>
          <option value="4" selected>4 × 4</option>
          <option value="5">5 × 5</option>
        </select>
      </div>

      <div class="group">
        <button id="shuffle" class="btn">Mezclar</button>
        <button id="solve" class="btn-ghost">Resolver</button>
      </div>

      <div class="stats">
        <div>Movimientos: <strong id="moves">0</strong></div>
        <div>Tiempo: <strong id="time">00:00</strong></div>
      </div>
    </section>

    <section class="layout">
      <div id="board" class="board" aria-label="Tablero del rompecabezas" role="grid"></div>

      <figure class="preview">
        <figcaption>Imagen de referencia</figcaption>
        <img
          id="preview"
          alt="Vista previa del rompecabezas"
          src="<%= ctx %>/assets/img/curinca.png"
        />
      </figure>
    </section>

    <div class="help">
      <ul>
        <li><b>Click/Tap:</b> mueve una pieza adyacente al hueco.</li>
        <li><b>Teclado:</b> usa ↑ ↓ ← → para mover el hueco.</li>
      </ul>
    </div>
  </div>

  <!-- Modal de victoria -->
  <div id="winModal" class="modal" hidden>
    <div class="card">
      <h2>¡Completado! 🏁</h2>
      <p>Tiempo: <b id="finalTime">—</b> · Movimientos: <b id="finalMoves">—</b></p>
      <div id="rewardArea" class="reward"></div>
      <button class="btn" id="playAgain">Jugar de nuevo</button>
    </div>
  </div>

  <!-- ================= JS INTEGRADO ================= -->
  <script>
(() => {
  // ========= PARÁMETROS =========
  const params       = new URLSearchParams(location.search);
  const IMG_FROM_QS  = params.get("img");
  const SIZE_FROM_QS = parseInt(params.get("size") || "4", 10);

  // Rutas de imágenes ABSOLUTAS (con contextPath)
  const ALT_IMAGES = [
    "<%= ctx %>/assets/img/curinca.png",
    "<%= ctx %>/assets/img/sierra_nevada.png",
    "<%= ctx %>/assets/img/piscina_olimpica.png",
    "<%= ctx %>/assets/img/coliseo_menor.png",
  ];

  // Si viene ?img=..., debe ser ruta absoluta. Si no, una de las anteriores
  const IMG_SRC = IMG_FROM_QS || ALT_IMAGES[Math.floor(Math.random() * ALT_IMAGES.length)];

  // Límite duro por tamaño (segundos)
  const TIME_LIMIT = { 3: 120, 4: 210, 5: 360 };

  // Metas para medallas (se evalúan con el tiempo empleado)
  const TIME_GOALS = {
    3: { oro: 60,  plata: 90,  bronce: 120 },
    4: { oro: 120, plata: 180, bronce: 240 },
    5: { oro: 240, plata: 300, bronce: 360 }
  };

  // Descuento escala con el tamaño
  const DISCOUNT_BY_SIZE = {
    3: { oro: 8,  plata: 5,  bronce: 3 },
    4: { oro: 12, plata: 8,  bronce: 5 },
    5: { oro: 18, plata: 12, bronce: 8 }
  };

  // ========= UI =========
  const boardEl      = document.getElementById("board");
  const sizeSel      = document.getElementById("size");
  const btnShuffle   = document.getElementById("shuffle");
  const btnSolve     = document.getElementById("solve");
  const movesEl      = document.getElementById("moves");
  const timeEl       = document.getElementById("time");
  const previewEl    = document.getElementById("preview");
  const winModal     = document.getElementById("winModal");
  const finalTimeEl  = document.getElementById("finalTime");
  const finalMovesEl = document.getElementById("finalMoves");
  const playAgain    = document.getElementById("playAgain");
  const rewardArea   = document.getElementById("rewardArea");

  if (previewEl) previewEl.src = IMG_SRC;

  let N = Number.isFinite(SIZE_FROM_QS) ? SIZE_FROM_QS : 4;
  if (sizeSel) sizeSel.value = String(N);

  // ========= ESTADO =========
  let tiles   = []; // 0..N*N-1 ; 0 = hueco
  let moves   = 0;
  let started = false;

  let timer    = null;
  let timeLeft = TIME_LIMIT[N];   // segundos restantes
  let expired  = false;

  // ========= UTILS =========
  const fmt = s => {
    const m = Math.floor(s / 60);
    const sec = s % 60;
    return (m < 10 ? "0" + m : "" + m) + ":" + (sec < 10 ? "0" + sec : "" + sec);
  };

  function updateTimeUI(){
    if (!timeEl) return;
    timeEl.textContent = fmt(Math.max(0, timeLeft));
  }

  function startTimer(){
    if (timer) return;
    timer = setInterval(() => {
      timeLeft--;
      updateTimeUI();
      if (timeLeft <= 0){
        timeLeft = 0;
        stopTimer();
        onTimeUp();
      }
    }, 1000);
  }

  function stopTimer(){
    if (!timer) return;
    clearInterval(timer);
    timer = null;
  }

  function resetStats(){
    moves   = 0;
    started = false;
    expired = false;
    timeLeft = TIME_LIMIT[N] || 0;
    if (movesEl) movesEl.textContent = "0";
    updateTimeUI();
    if (boardEl) boardEl.classList.remove("disabled");
  }

  const indexToPos = i => ({ r: Math.floor(i / N), c: i % N });
  const posToIndex = (r,c) => r * N + c;
  const getEmptyIndex = () => tiles.indexOf(0);

  const neighborsOf = index => {
    const pos = indexToPos(index);
    const r = pos.r;
    const c = pos.c;
    const list = [];
    if (r > 0)   list.push(posToIndex(r-1, c));
    if (r < N-1) list.push(posToIndex(r+1, c));
    if (c > 0)   list.push(posToIndex(r, c-1));
    if (c < N-1) list.push(posToIndex(r, c+1));
    return list;
  };

  const canMove = i => !expired && neighborsOf(i).includes(getEmptyIndex());
  const swap = (i,j) => {
    const tmp = tiles[i];
    tiles[i]  = tiles[j];
    tiles[j]  = tmp;
  };

  const isSolved = () => tiles.every((v,i)=> (i === tiles.length - 1 ? v === 0 : v === i + 1));

  function inversions(arr){
    const vals = arr.filter(x => x !== 0);
    let inv = 0;
    for (let i = 0; i < vals.length; i++){
      for (let j = i + 1; j < vals.length; j++){
        if (vals[i] > vals[j]) inv++;
      }
    }
    return inv;
  }

  function isSolvable(arr){
    const inv = inversions(arr);
    if (N % 2 === 1) return inv % 2 === 0;
    const emptyRowFromTop    = Math.floor(arr.indexOf(0) / N);
    const emptyRowFromBottom = N - emptyRowFromTop;
    return (emptyRowFromBottom % 2 === 0) ? (inv % 2 === 1) : (inv % 2 === 0);
  }

  function isSolvedBase(arr){
    for (let i=0; i<arr.length-1; i++){
      if (arr[i] !== i+1) return false;
    }
    return arr[arr.length-1] === 0;
  }

  function makeSolvableShuffle(){
    const base = [];
    for (let i=0; i < N*N; i++) base.push(i);
    do {
      for (let i = base.length-1; i > 0; i--){
        const j = Math.floor(Math.random() * (i+1));
        const tmp = base[i];
        base[i] = base[j];
        base[j] = tmp;
      }
    } while(!isSolvable(base) || isSolvedBase(base));
    return base;
  }

  // ========= RENDER =========
  function render(){
    const tileSize = 100 / N;
    boardEl.innerHTML = "";

    for (let i = 0; i < tiles.length; i++){
      const v = tiles[i];
      const pos = indexToPos(i);
      const r = pos.r;
      const c = pos.c;

      const el = document.createElement("button");
      el.className = "tile";
      el.style.position = "absolute";
      el.style.width  = tileSize + "%";
      el.style.height = tileSize + "%";
      el.style.left   = (c * tileSize) + "%";
      el.style.top    = (r * tileSize) + "%";

      if (v === 0){
        el.classList.add("empty");
        boardEl.appendChild(el);
        continue;
      }

      const targetIndex = v - 1;
      const tpos = indexToPos(targetIndex);
      const tr = tpos.r;
      const tc = tpos.c;

      el.style.backgroundImage    = "url('" + IMG_SRC + "')";
      el.style.backgroundSize     = (N*100) + "% " + (N*100) + "%";
      el.style.backgroundPosition =
        (tc * (100/(N-1))) + "% " + (tr * (100/(N-1))) + "%";
      el.style.backgroundRepeat   = "no-repeat";

      (function(idx){
        el.addEventListener("click", function(){
          move(idx);
        });
      })(i);

      boardEl.appendChild(el);
    }

    boardEl.classList.toggle("disabled", expired);
  }

  // ========= MOVIMIENTO / VICTORIA / TIEMPO =========
  function move(tileIndex){
    if (!canMove(tileIndex)) return;
    swap(tileIndex, getEmptyIndex());
    moves++;
    if (movesEl) movesEl.textContent = String(moves);
    if (!started){
      started = true;
      startTimer();
    }
    render();
    if (isSolved()) onWin();
  }

  function onTimeUp(){
    expired = true;
    boardEl.classList.add("disabled");
    if (finalMovesEl) finalMovesEl.textContent = String(moves);
    if (finalTimeEl)  finalTimeEl.textContent  = fmt(TIME_LIMIT[N]);
    if (rewardArea)   rewardArea.textContent   = "Tiempo agotado ⏳ · Sin descuento.";
    if (winModal)     winModal.hidden = false;
  }

  function onWin(){
    stopTimer();
    const elapsed = (TIME_LIMIT[N] || 0) - timeLeft;
    if (finalMovesEl) finalMovesEl.textContent = String(moves);
    if (finalTimeEl)  finalTimeEl.textContent  = fmt(Math.max(0, elapsed));

    if (timeLeft <= 0){
      if (rewardArea) rewardArea.textContent = "Terminaste, pero fuera de tiempo. Sin descuento.";
      if (winModal) winModal.hidden = false;
      return;
    }

    const metas = TIME_GOALS[N] || {};
    let tier = null;
    if      (elapsed <= metas.oro)    tier = "oro";
    else if (elapsed <= metas.plata)  tier = "plata";
    else if (elapsed <= metas.bronce) tier = "bronce";

    if (!tier){
      if (rewardArea) rewardArea.textContent = "Terminaste dentro del tiempo, pero sin alcanzar metas de medalla.";
      if (winModal) winModal.hidden = false;
      return;
    }

    const pct  = (DISCOUNT_BY_SIZE[N] && DISCOUNT_BY_SIZE[N][tier]) || 0;
    const code = "PUZ-" + tier.toUpperCase() + "-" +
                 Math.random().toString(36).slice(2,6).toUpperCase();

    if (rewardArea){
      rewardArea.innerHTML =
        "<p>🎉 ¡Ganaste <b>" + pct +
        "%</b> de descuento (medalla <b>" + tier +
        "</b>, " + N + "×" + N + ")</p>" +
        '<p style="color:#666">Cupón: <b>' + code + "</b></p>";
    }
    if (winModal) winModal.hidden = false;
  }

  // ========= CONTROL =========
  function newGame(){
    tiles = makeSolvableShuffle();
    stopTimer();
    resetStats();
    render();
  }

  function solveGame(){
    tiles = [];
    for (let i=0; i<N*N; i++){
      tiles.push(i === N*N-1 ? 0 : i+1);
    }
    stopTimer();
    resetStats();
    render();
  }

  function onKey(e){
    if (expired) return;
    const key = e.key;
    const empty = getEmptyIndex();
    const pos  = indexToPos(empty);
    const r = pos.r;
    const c = pos.c;
    let target = null;
    if (key === "ArrowUp"    && r < N-1) target = posToIndex(r+1, c);
    if (key === "ArrowDown"  && r > 0)   target = posToIndex(r-1, c);
    if (key === "ArrowLeft"  && c < N-1) target = posToIndex(r, c+1);
    if (key === "ArrowRight" && c > 0)   target = posToIndex(r, c-1);
    if (target !== null){
      move(target);
      if (!started){
        started = true;
        startTimer();
      }
      e.preventDefault();
    }
  }

  document.addEventListener("keydown", onKey, { passive:false });
  if (btnShuffle) btnShuffle.addEventListener("click", newGame);
  if (btnSolve)   btnSolve.addEventListener("click", solveGame);
  if (sizeSel)    sizeSel.addEventListener("change", function(){
    N = parseInt(sizeSel.value, 10);
    timeLeft = TIME_LIMIT[N] || 0;
    newGame();
  });
  if (playAgain)  playAgain.addEventListener("click", function(){
    if (winModal) winModal.hidden = true;
    newGame();
  });

  // ========= INIT =========
  newGame();

})();
  </script>
</body>
</html>



