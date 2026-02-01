// Stefano Luciano Developed: Orologio Stellare Script
const container = document.getElementById('stars-container');
const sound = document.getElementById('starSound');

function playSound() {
    sound.pause();
    sound.currentTime = 0;
    sound.volume = 1.0;
    sound.muted = false;

    console.log('Attempting to play sound:', sound.src);
    
    const playPromise = sound.play();
    if (playPromise !== undefined) {
        playPromise.catch((error) => {
            console.log('Audio blocked, retrying...', error);
            setTimeout(() => {
                sound.play().catch(e => console.log('Audio retry failed:', e));
            }, 100);
        });
    } else {
        console.log('Audio playing successfully');
    }
}

function stopSound() {
    sound.pause();
    sound.currentTime = 0;
}

// Stelle statiche che appaiono all'inizio
function createStaticStars() {
    for (let i = 0; i < 50; i++) {
        const star = document.createElement('div');
        star.className = 'static-star';
        star.style.left = Math.random() * 100 + '%';
        star.style.top = Math.random() * 100 + '%';
        star.style.width = Math.random() * 3 + 1 + 'px';
        star.style.height = star.style.width;
        star.style.background = '#ffffff';
        star.style.boxShadow = '0 0 10px #c77dff';
        star.style.opacity = Math.random() * 0.8 + 0.2;
        container.appendChild(star);
    }
}

function spawnComet() {
    const c = document.createElement('div');
    c.className = 'comet';

    c.style.left = `${window.innerWidth + Math.random() * 400}px`;
    c.style.top = `${-100 - Math.random() * 300}px`;
    c.style.animationDuration = `${3 + Math.random() * 2}s`;

    container.appendChild(c);

    setTimeout(() => {
        c.remove();
    }, 6000);
}

/* PIOGGIA DI COMETE */
let cometInterval = null;

window.addEventListener('message', (e) => {
    if (e.data.action === 'showStellare') {
        document.body.classList.remove('hidden');
        
        // Force audio load if not ready
        if (sound.readyState < 2) {
            sound.load();
        }
        
        if (e.data.sound) {
            playSound();
        }
        
        // Crea stelle statiche all'inizio
        createStaticStars();

        cometInterval = setInterval(() => {
            for (let i = 0; i < 8; i++) {
                spawnComet();
            }
        }, 150);
    }

    if (e.data.action === 'hideStellare') {
        document.body.classList.add('hidden');
        stopSound();
        clearInterval(cometInterval);

        // Rimuovi tutto
        container.innerHTML = '';
    }
});
