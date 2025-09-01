// Simple smooth scroll for sidebar links
document.querySelectorAll('.md-nav__link').forEach(link => {
    link.addEventListener('click', (e) => {
        const targetId = link.getAttribute('href').substring(1);
        const targetElem = document.getElementById(targetId);
        if (targetElem) {
            e.preventDefault();
            targetElem.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }
    });
});

// Highlight active sidebar item
window.addEventListener('scroll', () => {
    const sections = document.querySelectorAll('main.md-main section, main.md-main h2, main.md-main h3');
    let scrollPos = window.scrollY || window.pageYOffset;
    sections.forEach(section => {
        const top = section.offsetTop - 80;
        const bottom = top + section.offsetHeight;
        const id = section.id;
        const link = document.querySelector(`.md-nav__link[href="#${id}"]`);
        if (link) {
            if (scrollPos >= top && scrollPos < bottom) {
                link.classList.add('active');
            } else {
                link.classList.remove('active');
            }
        }
    });
});
