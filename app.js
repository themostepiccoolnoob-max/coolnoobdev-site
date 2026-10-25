const homeView = document.getElementById('home-view');
const tutorialViews = {
  sprint: document.getElementById('sprint-tutorial'),
  crouch: document.getElementById('crouch-tutorial'),
  daynight: document.getElementById('daynight-tutorial'),
  redeem: document.getElementById('redeem-tutorial'),
  welcome: document.getElementById('welcome-tutorial'),
  customtools: document.getElementById('customtools-tutorial'),
  objective: document.getElementById('objective-tutorial'),
  sprintstamina: document.getElementById('sprintstamina-tutorial'),
  custommenu: document.getElementById('custommenu-tutorial'),
  enemynpc: document.getElementById('enemynpc-tutorial'),
  gamepasstool: document.getElementById('gamepasstool-tutorial'),
  mobilegui: document.getElementById('mobilegui-tutorial'),
  customanimations: document.getElementById('customanimations-tutorial'),
  sprintshiftctrl: document.getElementById('sprintshiftctrl-tutorial')
};
const toast = document.getElementById('toast');

async function loadCode(file, elementId) {
  const element = document.getElementById(elementId);
  if (!element) return;
  try {
    const response = await fetch(file);
    if (!response.ok) throw new Error('Could not load script');
    element.textContent = await response.text();
  } catch {
    element.textContent = 'The script could not load. Use the Download button to get the Lua file.';
  }
}
function showTutorial(name) {
  homeView.classList.add('hidden');
  Object.values(tutorialViews).forEach(view => view.classList.add('hidden'));
  tutorialViews[name].classList.remove('hidden');
  const routes = {sprint:'custom-sprint-animations', crouch:'crouch-system', daynight:'day-night-cycle', redeem:'redeem-codes-system', welcome:'welcome-badge', customtools:'custom-tool-animations', objective:'objective-system', sprintstamina:'sprint-stamina-system', custommenu:'customisable-main-menu', enemynpc:'enemy-npc', gamepasstool:'gamepass-tool', mobilegui:'mobile-gui', customanimations:'custom-roblox-animations', sprintshiftctrl:'custom-sprint-animations-shift-ctrl'};
  history.replaceState(null, '', `#${routes[name]}`);
  window.scrollTo({top:0,behavior:'smooth'});
}
function showHome() {
  Object.values(tutorialViews).forEach(view => view.classList.add('hidden'));
  homeView.classList.remove('hidden');
  history.replaceState(null, '', '#home');
  window.scrollTo({top:0,behavior:'smooth'});
}
document.querySelectorAll('[data-tutorial]').forEach(button => {
  button.addEventListener('click', () => showTutorial(button.dataset.tutorial));
});
document.querySelectorAll('[data-back-home]').forEach(button => button.addEventListener('click', showHome));
document.getElementById('nav-home').addEventListener('click', event => {
  event.preventDefault();
  showHome();
});
function openRoute() {
  const routes = {'#crouch-system':'crouch', '#custom-sprint-animations':'sprint', '#day-night-cycle':'daynight', '#redeem-codes-system':'redeem', '#welcome-badge':'welcome', '#custom-tool-animations':'customtools', '#objective-system':'objective', '#sprint-stamina-system':'sprintstamina', '#customisable-main-menu':'custommenu', '#enemy-npc':'enemynpc', '#gamepass-tool':'gamepasstool', '#mobile-gui':'mobilegui', '#custom-roblox-animations':'customanimations', '#custom-sprint-animations-shift-ctrl':'sprintshiftctrl'};
  if (routes[location.hash]) showTutorial(routes[location.hash]);
  else showHome();
}
openRoute();
loadCode('custom-sprint-animations.lua', 'script-code');
loadCode('custom-roblox-animations.lua', 'customanimations-code');
loadCode('custom-sprint-animations-shift-ctrl.lua', 'sprintshiftctrl-code');
loadCode('day-night-cycle.lua', 'daynight-code');
loadCode('welcome-badge.lua', 'welcome-code');
loadCode('sprint-stamina.lua', 'sprintstamina-code');
loadCode('gamepass-tool-client.lua', 'gamepass-client-code');
loadCode('gamepass-tool-server.lua', 'gamepass-server-code');
document.getElementById('year').textContent = new Date().getFullYear();

const searchInput = document.getElementById('search');
const guideCount = document.getElementById('guide-count');
const searchEmpty = document.getElementById('search-empty');
const tutorialCards = [...document.querySelectorAll('[data-tutorial]')];
tutorialCards.forEach(card => {
  const year = card.dataset.year;
  if (!year) return;
  const label = document.createElement('span');
  label.className = 'card-year';
  label.textContent = year;
  label.setAttribute('aria-label', `Tutorial year ${year}`);
  card.querySelector('.card-content')?.append(label);
});
const searchAliases = {
  sprint: 'stamina run running shift movement speed',
  crouch: 'duck sneak movement r6 r15',
  daynight: 'day night lighting time clock cycle',
  redeem: 'codes gui rewards model',
  welcome: 'badge award player join',
  customtools: 'tool animation model',
  objective: 'quest task mission pickup model',
  sprintstamina: 'sprint run stamina bar movement',
  custommenu: 'main menu gui interface model',
  enemynpc: 'enemy npc combat model',
  gamepasstool: 'game pass gamepass purchase tool sword local server script',
  mobilegui: 'mobile gui interface autoscale autoscale lite plugin phone screen scale',
  customanimations: 'custom roblox animations mobile model avatar animation system',
  sprintshiftctrl: 'sprint custom animation shift ctrl control walk idle jump movement'
};
function updateSearch() {
  const terms = searchInput.value.toLocaleLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '').match(/[a-z0-9]+/g) || [];
  let visible = 0;
  tutorialCards.forEach(card => {
    const searchable = `${card.textContent} ${searchAliases[card.dataset.tutorial] || ''}`.toLocaleLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '');
    const matches = terms.every(term => searchable.includes(term));
    card.hidden = !matches;
    if (matches) visible++;
  });
  const searching = terms.length > 0;
  if (guideCount) guideCount.textContent = searching ? `${visible} OF ${tutorialCards.length} GUIDES` : `${tutorialCards.length} GUIDES`;
  searchEmpty.classList.toggle('hidden', !searching || visible > 0);
  document.querySelector('.coming-soon')?.classList.toggle('hidden', searching);
}
searchInput.addEventListener('input', updateSearch);
document.getElementById('clear-search').addEventListener('click', () => {
  searchInput.value = '';
  updateSearch();
  searchInput.focus();
});
document.addEventListener('keydown', event => {
  if (event.key === '/' && document.activeElement.tagName !== 'INPUT') {
    event.preventDefault();
    document.getElementById('search').focus();
  }
  if (event.key === 'Escape' && !homeView.classList.contains('hidden')) return;
  if (event.key === 'Escape') showHome();
});
function setupCopy(buttonId, codeId) {
  const button = document.getElementById(buttonId);
  const code = document.getElementById(codeId);
  if (!button || !code) return;
  button.addEventListener('click', async () => {
    try {
      await navigator.clipboard.writeText(code.textContent);
      button.innerHTML = '<span class="copy-glyph">✓</span> Copied!';
      toast.textContent = 'Script copied!';
      toast.classList.add('show');
      setTimeout(() => { toast.classList.remove('show'); button.innerHTML = '<img class="copy-icon" src="copy-icon.png" alt="" aria-hidden="true"> Copy script'; }, 1800);
    } catch {
      toast.textContent = 'Copy failed — select the code and copy it manually.';
      toast.classList.add('show');
      setTimeout(() => toast.classList.remove('show'), 2400);
    }
  });
}
setupCopy('copy-script', 'script-code');
setupCopy('copy-customanimations', 'customanimations-code');
setupCopy('copy-sprintshiftctrl', 'sprintshiftctrl-code');
setupCopy('copy-daynight', 'daynight-code');
setupCopy('copy-welcome', 'welcome-code');
setupCopy('copy-sprintstamina', 'sprintstamina-code');
setupCopy('copy-gamepass-client', 'gamepass-client-code');
setupCopy('copy-gamepass-server', 'gamepass-server-code');
