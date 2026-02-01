# ⭐ Orologio Stellare - Sistema Standalone

Un sistema completo di revive automatico per FiveM con effetti visivi spettacolari e cooldown di 30 minuti. Separato dalla risorsa Runa_System per evitare conflitti NUI.

## 🎮 Caratteristiche

### ⚡ **Funzionalità Principali**
- **Revive automatico** alla morte se l'orologio è nell'inventario
- **Uso manuale** dall'inventario ox_inventory
- **Cooldown di 30 minuti** tracciato server-side
- **Effetti visivi** con fumo e particelle cosmiche
- **Animazione stellare** con suoni custom
- **Sistema NUI dedicato** senza conflitti

### 🎨 **Effetti Visivi**
- **Pioggia di comete** animate
- **Stelle statiche** con effetto twinkle
- **Testo luminoso** con animazioni glow
- **Fumo e particelle** visibili a tutti i player
- **Audio immersivo** con suoni cosmici

## 📁 Struttura File

```
stellare_watch/
├── fxmanifest.lua          # Configurazione risorsa
├── README.md              # Documentazione
├── client/
│   └── stellareWatch.lua  # Logica client-side
├── server/
│   └── stellareWatch.lua  # Logica server-side
└── nui/
    ├── index.html         # Interfaccia principale
    ├── style.css          # Stile CSS
    ├── script.js          # Logica JavaScript
    └── sound.mp3          # Audio effetti
```

## 🛠️ Installazione

### 📋 Prerequisiti
- **FiveM Server** aggiornato
- **ox_lib** - Framework utility
- **ox_inventory** - Gestione inventario
- **qb-core** - Framework principale

### 📦 Installazione
1. Copia la cartella `stellare_watch/` in `resources/`
2. Aggiungi al `server.cfg`:
   ```
   ensure ox_lib
   ensure ox_inventory
   ensure qb-core
   ensure stellare_watch
   ```
3. Riavvia il server

### 🎯 Configurazione Item
Aggiungi questo item al tuo `ox_inventory/data/items.lua`:
```lua
['orologiostellare'] = {
    label = 'Orologio Stellare',
    weight = 0.5,
    stack = true,
    close = true,
    description = 'Orologio magico che ti revive automaticamente quando muori. Cooldown di 30 minuti.',
    client = {
        export = 'orologiostellare:use'
    }
}
```

## 🎮 Come Usare

### ⚡ **Funzionamento Automatico**
1. **Ottieni l'orologio** dal Dalgona Game o altro sistema
2. **Muori** durante il gameplay
3. **Sistema rileva** automaticamente la morte
4. **Controlla inventario** per presenza orologio
5. **Attiva effetti** visivi e sonori
6. **Revive automatico** dopo 7 secondi
7. **Imposta cooldown** di 30 minuti

### 🔧 **Uso Manuale**
1. **Apri inventario** ox_inventory
2. **Seleziona orologio** stellare
3. **Usa item** per attivare manualmente
4. **Stessi effetti** della versione automatica

### ⏰ **Cooldown System**
- **30 minuti** di cooldown dopo l'uso
- **Tracciamento server-side** persistente
- **Notifiche dettagliate** con tempo rimanente
- **Reset automatico** allo scadere

## 🎛️ Comandi Admin

### 📋 **Comandi Disponibili**
```bash
# Controlla cooldown player
/stellare_cooldown [playerId]

# Resetta cooldown player
/stellare_reset [playerId]
```

## 🔧 Configurazione

### ⚙️ **Personalizzazione**
Puoi modificare questi parametri nei file:

**Cooldown (server/stellareWatch.lua):**
```lua
-- Modifica durata cooldown (secondi)
stellareCooldowns[source] = os.time() + (30 * 60) -- 30 minuti
```

**Effetti visivi (client/stellareWatch.lua):**
```lua
-- Modifica durata animazione
Wait(7000) -- 7 secondi di cinematica

-- Modifica numero particelle
for i = 1, 5 do -- 5 effetti di fumo
```

## 🔗 Integrazioni

### 📦 **Esportazioni**
```lua
-- Uso manuale dall'inventario
exports['stellare_watch']:orologiostellare:use(data, slot)
```

### 🎯 **Eventi**
```lua
-- Client: Attivazione orologio
TriggerEvent('QBCore:Client:OnPlayerDeath')

-- Server: Risposta uso orologio
TriggerClientEvent('stellare:watchResult', source, success)
```

## 🐛 Troubleshooting

### ❌ **Problemi Comuni**

**Orologio non si attiva:**
- Controlla che `stellare_watch` sia caricato dopo `ox_inventory`
- Verifica che l'item sia configurato correttamente
- Controlla la console per errori

**Audio non funziona:**
- Verifica file `sound.mp3` presente in `nui/`
- Controlla permessi browser FiveM
- Prova ad aggiornare FiveM

**Effetti visivi non appaiono:**
- Controlla file CSS e JavaScript
- Verifica console F8 per errori NUI
- Assicurati che `SetNuiFocus` funzioni

**Cooldown non funziona:**
- Controlla log server per messaggi
- Verifica che `os.time()` funzioni
- Usa comandi admin per debug

### 📝 **Log Utili**
Il sistema genera log dettagliati:
```
[Stellare Watch] Sistema orologio stellare inizializzato
[Stellare Watch] Player Nome ha usato l'orologio stellare
```

## 🎨 Customizzazione

### 🎭 **Modifica Aspetto**
Puoi personalizzare l'aspetto modificando:
- `nui/style.css` - Colori e animazioni
- `nui/script.js` - Comportamento JavaScript
- `nui/index.html` - Struttura HTML

### 🎵 **Audio Personalizzato**
Sostituisci `nui/sound.mp3` con il tuo file audio e aggiorna il nome in `index.html`.

### ✨ **Effetti Particelle**
Modifica le particelle in `client/stellareWatch.lua`:
```lua
-- Cambia tipo particella
UseParticleFxAssetNextCall('core')
local smoke = StartParticleFxLoopedAtCoord('exp_grd_grenade_smoke', ...)
```

## 📄 Licenza

**Autore:** Stefano Luciano Corp  
**Versione:** 1.0.0  
**Framework:** QBCore Compatible  
**FiveM Version:** Latest

## 🤝 Supporto

Per supporto e segnalazioni bug:
- **Discord:** [Tuo Discord]
- **GitHub:** [Tuo Repository]

---

**⚠️ NOTA:** Questa è una risorsa standalone. Non richiede Runa_System per funzionare.
