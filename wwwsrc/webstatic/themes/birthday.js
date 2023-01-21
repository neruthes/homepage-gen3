setTimeout(function () {
    const banner = document.createElement('div');
    console.log(banner);
    banner.id = 'fc337e332fe847be8275058ae850a39d'
    banner.setAttribute('style', `position: absolute; top: 0px; width: 100vw; font-size: ${Math.floor(Math.min(screen.availHeight, screen.availWidth))/16}px; text-align: center; padding: 10px 0px;`);
    banner.innerHTML = `<span id="b004064ca28836293b62" style="opacity: 0;">🎂<span>`
    // (new Array(Math.floor(screen.availWidth / 20 * 0.5))).fill('🎂').join(' ');
    document.body.prepend(banner);
    const span = document.querySelector('#b004064ca28836293b62');
    const originalOffsetHeight = span.offsetHeight
    for (let itr = 0; itr < 200; itr++) {
        if (span.offsetHeight <= originalOffsetHeight + 1) {
            span.innerHTML += ' 🎂';
            console.log('🎂');
        };
    };
    span.innerHTML = span.innerHTML.replace('🎂 🎂 ', '');
    span.style.opacity = '1';

    const bodyTopExtraPadding = document.createElement('div');
    bodyTopExtraPadding.setAttribute('style', `height: ${document.querySelector('#fc337e332fe847be8275058ae850a39d').offsetHeight + 'px'};`);
    bodyTopExtraPadding.setAttribute('class', `pinMySize`);
    document.body.prepend(bodyTopExtraPadding);
}, 1000)
