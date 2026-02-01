// ===== STATE MANAGEMENT =====
const STATE = {
  NONE: 'NONE',
  RUNE_SELECTION: 'RUNE_SELECTION',
  CONFIRM_COST: 'CONFIRM_COST',
  RITUAL: 'RITUAL',
  RESULT: 'RESULT'
};

let currentState = STATE.NONE;
let selectedRuneData = null;

// ===== UI ELEMENTS =====
const elements = {
  craftingMenu: document.getElementById('crafting-menu'),
  phase2: document.getElementById('upgrade-progress'),
  runeSelection: document.getElementById('rune-selection'),
  selectedRuneBox: document.getElementById('selected-rune'),
  selectedName: document.getElementById('selected-name'),
  confirmBtn: document.getElementById('confirm-button'),
  upgradeBtn: document.getElementById('upgrade-button'),
  ritualTimer: document.getElementById('ritual-timer'),
  ritualMessage: document.getElementById('ritual-message'),
  upgradeResult: document.getElementById('upgrade-result'),
  resultTitle: document.getElementById('result-title'),
  resultMessage: document.getElementById('result-message'),
  continueResultBtn: document.getElementById('continue-result-btn'),
  closeResultBtn: document.getElementById('close-result-btn'),
  notification: document.getElementById('upgrade-notification'),
  notificationTitle: document.getElementById('notification-title'),
  notificationMessage: document.getElementById('notification-message')
};

// ===== RUNE CONFIGURATION =====
const runes = [
  { type: 'speed', name: 'Runa della Velocità', image: 'runa_speed.png', divinas: ['runa_speed_divina'] },
  { type: 'hp', name: 'Runa della Vita', image: 'runa_hp.png', divinas: ['runa_hp_divina'] },
  { type: 'mp', name: 'Runa del Mana', image: 'runa_mp.png', divinas: ['runa_mp_divina'] },
  { type: 'danno', name: 'Runa del Danno', image: 'runa_danno.png', divinas: ['runa_danno_divina'] },
  { type: 'cdr', name: 'Runa del Rid. Cooldown', image: 'runa_cdr.png', divinas: ['runa_cdr_divina'] }
];

// ===== EVENT LISTENERS =====
function setupEventListeners() {
  // Close button - chiude l'UI e rimuove focus
  document.getElementById('close-button').addEventListener('click', () => {
    console.log('[UI] Close button clicked');
    SetNuiFocus(false, false);
    sendNUI('closeCrafting');
    resetUI();
    setState(STATE.NONE);
  });

  document.getElementById('close-phase2-button').addEventListener('click', () => {
    elements.phase2.classList.add('hidden');
    elements.craftingMenu.classList.remove('hidden');
    setState(STATE.RUNE_SELECTION);
  });

  // Confirm button - move to cost confirmation
  elements.confirmBtn.addEventListener('click', () => {
    if (!selectedRuneData) return;
    elements.craftingMenu.classList.add('hidden');
    elements.phase2.classList.remove('hidden');
    setState(STATE.CONFIRM_COST);
  });

  // Upgrade button - start ritual
  elements.upgradeBtn.addEventListener('click', () => {
    executeUpgrade();
  });

  // Continue/Close result buttons
  elements.continueResultBtn.addEventListener('click', () => {
    // Go back to rune selection with same rune
    elements.phase2.classList.add('hidden');
    elements.craftingMenu.classList.remove('hidden');
    elements.upgradeResult.classList.add('hidden');
    elements.upgradeResult.classList.remove('success', 'failure');
    elements.upgradeResult.querySelector('.result-title').textContent = '';
    elements.upgradeResult.querySelector('.result-message').textContent = '';
    setState(STATE.RUNE_SELECTION);
  });

  elements.closeResultBtn.addEventListener('click', () => {
    SetNuiFocus(false, false);
    sendNUI('closeCrafting');
    resetUI();
    setState(STATE.NONE);
  });
}

// ===== STATE MANAGEMENT =====
function setState(newState) {
  currentState = newState;
  console.log(`[UI State] Transitioned to: ${newState}`);
}

// ===== RENDER FUNCTIONS =====
function renderRuneSelection(inventory) {
  console.log('[UI] renderRuneSelection called with inventory:', inventory);
  elements.runeSelection.innerHTML = '';
  
  // Se l'inventario è vuoto, mostra tutte le rune come disponibili
  const hasInventory = inventory && inventory.length > 0;
  
  runes.forEach(rune => {
    // Verifica se il giocatore ha questo tipo di rune
    let hasRune = false;
    let level = 0;
    let isDivine = false;
    let baseItem = null;
    
    if (hasInventory) {
      // Cerca nel database degli inventari del giocatore
      const playerRune = inventory.find(item => {
        if (!item) return false;
        const itemType = item.name?.toLowerCase() || '';
        const runeTypeLower = rune.type.toLowerCase();
        return itemType === 'runa_' + runeTypeLower || itemType === runeTypeLower;
      });
      
      if (playerRune) {
        hasRune = true;
        level = playerRune.metadata?.level || 0;
        isDivine = playerRune.metadata?.divina || rune.divinas.includes(playerRune.name);
        baseItem = playerRune;
      }
    } else {
      // Nessun inventario fornito, mostra tutte le rune
      hasRune = true;
      level = 0;
    }
    
    if (!hasRune) {
      // Mostra comunque la rune come non disponibile
      const div = document.createElement('div');
      div.className = 'rune-square disabled';
      div.dataset.type = rune.type;
      div.dataset.level = -1; // -1 = non disponibile
      
      div.innerHTML = `
        <img src="${rune.image}" alt="${rune.name}" style="opacity: 0.3;">
        <p style="opacity: 0.5;">${rune.name}</p>
        <p style="font-size: 11px; font-weight: normal; opacity: 0.5;">Non in inventario</p>
      `;
      
      elements.runeSelection.appendChild(div);
      return;
    }
    
    // Non mostrare rune al livello massimo (5)
    if (level >= 5) {
      const div = document.createElement('div');
      div.className = 'rune-square maxed';
      div.dataset.type = rune.type;
      div.dataset.level = level;
      
      div.innerHTML = `
        <img src="${isDivine ? 'runa_danno.png' : rune.image}" alt="${rune.name}">
        <p>${isDivine ? 'DIVINA +' + level : rune.name}</p>
        <p style="font-size: 11px; font-weight: normal; opacity: 0.8;">Livello massimo!</p>
      `;
      
      elements.runeSelection.appendChild(div);
      return;
    }
    
    const div = document.createElement('div');
    div.className = `rune-square${isDivine ? ' divine' : ''}`;
    div.dataset.type = rune.type;
    div.dataset.level = level;
    
    div.innerHTML = `
      <img src="${isDivine ? 'runa_danno.png' : rune.image}" alt="${rune.name}">
      <p>${isDivine ? 'DIVINA +' + level : rune.name}</p>
      <p style="font-size: 11px; font-weight: normal; opacity: 0.8;">Livello: ${level}/5</p>
      <p style="font-size: 11px; font-weight: normal; opacity: 0.6;">Costo: ${200}</p>
    `;
    
    div.addEventListener('click', () => selectRune(div, rune, level, isDivine, baseItem));
    elements.runeSelection.appendChild(div);
  });
  
  console.log('[UI] Rendered ' + elements.runeSelection.children.length + ' runes');
}

function selectRune(element, rune, level, isDivine, baseItem) {
  // Remove previous selection
  document.querySelectorAll('.rune-square').forEach(el => el.classList.remove('selected'));
  
  // Add selection to clicked element
  element.classList.add('selected');
  
  // Update selected rune display
  elements.selectedRuneBox.classList.remove('hidden');
  elements.selectedName.textContent = `${isDivine ? 'DIVINA ' : ''}${rune.name} +${level}`;
  elements.confirmBtn.classList.remove('hidden');
  
  // Store selection globally
  selectedRuneData = {
    type: rune.type,
    name: rune.name,
    level: level,
    isDivine: isDivine,
    baseItem: baseItem
  };
  
  console.log(`[DEBUG] Selected rune: ${rune.type} level: ${level} divine: ${isDivine}`);
}

// ===== UPGRADE EXECUTION =====
function executeUpgrade() {
  if (!selectedRuneData) return;
  
  console.log(`[DEBUG] executeUpgrade called with: type=${selectedRuneData.type}, level=${selectedRuneData.level}`);
  
  // Hide crafting, show ritual
  elements.craftingMenu.classList.add('hidden');
  elements.upgradeResult.classList.add('hidden');
  elements.phase2.classList.remove('hidden');
  
  // Update state
  setState(STATE.RITUAL);
  
  // Start ritual immediately
  startRitualSequence();
  
  // Send upgrade request to server
  sendNUI('executeUpgrade', {
    type: selectedRuneData.type,
    level: selectedRuneData.level
  });
  
  console.log('[UI] Ritual started, waiting for server response...');
}

// ===== RITUAL FUNCTIONS =====
function startRitualSequence() {
  // Hide result elements, show ritual
  elements.upgradeResult.classList.add('hidden');
  elements.upgradeResult.classList.remove('success', 'failure');
  elements.continueResultBtn.classList.add('hidden');
  elements.closeResultBtn.classList.add('hidden');
  elements.ritualTimer.classList.remove('hidden');
  elements.ritualMessage.classList.remove('hidden');
  
  let timeLeft = 3;
  elements.ritualTimer.textContent = timeLeft;
  
  const messages = [
    "Channeling ancient energies...",
    "The stone begins to glow...",
    "The runes are aligning...",
    "Power flows through the ritual..."
  ];
  let messageIndex = 0;
  
  const countdown = setInterval(() => {
    timeLeft--;
    elements.ritualTimer.textContent = timeLeft;
    
    if (timeLeft <= 0) {
      clearInterval(countdown);
      elements.ritualTimer.classList.add('hidden');
      elements.ritualMessage.textContent = "Waiting for ancient magic...";
      console.log('[UI] Ritual timer finished, still waiting for server...');
    } else {
      // Update message
      messageIndex = (messageIndex + 1) % messages.length;
      elements.ritualMessage.textContent = messages[messageIndex];
    }
  }, 1000);
}

function displayUpgradeResult(success, newLevel) {
  setState(STATE.RESULT);
  
  elements.ritualMessage.classList.add('hidden');
  elements.upgradeResult.classList.remove('hidden');
  
  if (success) {
    elements.upgradeResult.classList.add('success');
    elements.upgradeResult.querySelector('.result-title').textContent = '✨ Success! ✨';
    elements.upgradeResult.querySelector('.result-message').textContent = `The rune has ascended to level ${newLevel}!`;
    elements.continueResultBtn.classList.remove('hidden');
  } else {
    elements.upgradeResult.classList.add('failure');
    elements.upgradeResult.querySelector('.result-title').textContent = '💥 Failed! 💥';
    elements.upgradeResult.querySelector('.result-message').textContent = `The ritual failed and the rune was reduced to level ${newLevel}.`;
    elements.closeResultBtn.classList.remove('hidden');
  }
  
  console.log(`[UI] Upgrade result: success=${success}, newLevel=${newLevel}`);
}

// ===== NUI COMMUNICATION =====
function sendNUI(type, data = {}) {
  fetch(`https://${GetParentResourceName()}/${type}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  });
}

// ===== UI RESET =====
function resetUI() {
  currentState = STATE.NONE;
  selectedRuneData = null;
  
  // Hide all panels
  elements.craftingMenu?.classList.add('hidden');
  elements.phase2?.classList.add('hidden');
  elements.notification?.classList.add('hidden');
  
  // Reset selection
  elements.selectedRuneBox?.classList.add('hidden');
  elements.confirmBtn?.classList.add('hidden');
  
  // Reset result
  elements.upgradeResult?.classList.add('hidden');
  elements.upgradeResult?.classList.remove('success', 'failure');
  elements.continueResultBtn?.classList.add('hidden');
  elements.closeResultBtn?.classList.add('hidden');
  
  // Reset ritual
  elements.ritualTimer?.classList.remove('hidden');
  elements.ritualMessage?.classList.remove('hidden');
  
  console.log('[UI] Reset complete');
}

// ===== MESSAGE HANDLER =====
window.addEventListener('message', (event) => {
  const data = event.data;
  
  if (data.type === 'openCrafting') {
    setState(STATE.RUNE_SELECTION);
    elements.craftingMenu.classList.remove('hidden');
    renderRuneSelection(data.inventory || []);
  }
  else if (data.type === 'closeCrafting') {
    resetUI();
  }
  else if (data.type === 'showUpgradeResult') {
    // Server returned upgrade result, show it
    console.log('[UI] Received upgrade result from server:', data);
    displayUpgradeResult(data.success, data.newLevel);
  }
  else if (data.type === 'showNotification') {
    showNotification(data.title, data.message, data.duration || 3000);
  }
});

function showNotification(title, message, duration = 3000) {
  elements.notificationTitle.textContent = title;
  elements.notificationMessage.textContent = message;
  elements.notification.classList.remove('hidden');
  
  setTimeout(() => {
    elements.notification.classList.add('hidden');
  }, duration);
}

// ===== INITIALIZATION =====
console.log('[UI] Ancient Rune Forge loaded');
setupEventListeners();
