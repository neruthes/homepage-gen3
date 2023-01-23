(function () {
    if (document.querySelector('#js-introBio')) { document.querySelector('#js-introBio').style.maxWidth = '430px'; }

    const makeElement = function (align) {
        let div = document.createElement('div');
        div.setAttribute('class', `chunlian vertical ${align} pinMySize`);
        div.setAttribute('style', `position: fixed; top: 2vh; height: 96vh; width: 15.8vh; ${align}: 2vh;`)
        let img = document.createElement('img');
        img.setAttribute('class', '');
        img.setAttribute('src', ({
            left: 'https://pub-714f8d634e8f451d9f2fe91a4debfa23.r2.dev/keep/homepage-gen3/kotomatsu-chunlian-left.jpg--6157b2f047fae206f9d4ab7b9271b97d.jpg',
            right: 'https://pub-714f8d634e8f451d9f2fe91a4debfa23.r2.dev/keep/homepage-gen3/kotomatsu-chunlian-right.jpg--bebe87d86fd4be276332a0feaecb9586.jpg'
        })[align]);
        img.setAttribute('style', `max-height: 100%; max-width: 100%; display: block; margin: 0;`);
        div.appendChild(img);
        return div;
    };

    // Is screen wide enough?
    if (window.screen.availWidth > 1070) {
        document.body.appendChild(makeElement('right'));
        document.body.appendChild(makeElement('left'));
    };

    // Is screen tall enough?
    if (window.screen.availHeight > 700) {
        const hengpi = (function () {
            const div = document.createElement('div');
            div.setAttribute('class', 'chunlian hengpi pinMySize');
            div.setAttribute('style', `position: absolute; top: 2vh; width: 100vw; height: ${96 / 2152 * 350}vh; left: 0px;`);
            const img = document.createElement('img');
            // img.setAttribute('src', `https://neruthes.github.io/assets/other-images/kotomatsu-chunlian-hengpi.jpg`);
            img.setAttribute('src', `https://pub-714f8d634e8f451d9f2fe91a4debfa23.r2.dev/keep/homepage-gen3/kotomatsu-chunlian-hengpi.jpg--b685aabf957e061f28ed2699f98b3048.jpg`);
            img.setAttribute('style', `max-height: 100%; max-width: 100%; display: block; margin: 0 auto;`);
            img.setAttribute('class', '');
            div.appendChild(img);
            return div;
        })();
        document.body.appendChild(hengpi);
        document.addEventListener('scroll', function () {
            if (window.pageYOffset > window.screen.availHeight * 0.8) {
                document.body.setAttribute('data-should-hide-hengpi', 'true');
            } else {
                document.body.setAttribute('data-should-hide-hengpi', 'false');
            };
            const opacity = Math.max(0, (1 - 1.25 * (window.pageYOffset / window.screen.availHeight)));
            document.querySelector('.chunlian.hengpi').style.opacity = opacity;
        });
        const bodyTopExtraPadding = document.createElement('div');
        bodyTopExtraPadding.setAttribute('style', `height: 22vh;`);
        bodyTopExtraPadding.setAttribute('class', `pinMySize`);
        document.body.prepend(bodyTopExtraPadding);
    };
})();
