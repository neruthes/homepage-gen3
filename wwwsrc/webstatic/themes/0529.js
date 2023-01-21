// Μες την Άγια Σοφιά θα βρεθούμε ξανά


setTimeout(function () {
    const wpurl = 'https://el.wikipedia.org/wiki/%CE%9A%CF%89%CE%BD%CF%83%CF%84%CE%B1%CE%BD%CF%84%CE%AF%CE%BD%CE%BF%CF%82_%CE%99%CE%91%CE%84_%CE%A0%CE%B1%CE%BB%CE%B1%CE%B9%CE%BF%CE%BB%CF%8C%CE%B3%CE%BF%CF%82'

    const banner = document.createElement('div');
    console.log(banner);
    banner.id = 'edfbbf782c4142aa8b493971a2b06b67'
    banner.setAttribute('style', `font-family: 'Brygada 1918', 'Century Schoolbook', 'Apple Color Emoji', 'Noto Color Emoji', sans-serif; font-size: 15px; text-align: center; padding: 10px 0px;`);
    banner.innerHTML = `<span style="display: inline-block; width: 28px;">🕯</span>
    <a style="text-decoration: none; display: inline-block; width: calc(100vw-90px);" href="${wpurl}">
        <span style="display: inline-block;">Μες την Άγια Σοφιά</span>
        <span style="display: inline-block;">θα βρεθούμε ξανά</span>
        <span style="display: inline-block;">λειτουργία μελλοντική</span>
        <span style="display: inline-block;">οι Έλληνες μαζί</span>
    </a>
    <span style="display: inline-block; width: 28px;">🕯</span>`;
    // (new Array(Math.floor(screen.availWidth / 20 * 0.5))).fill('🎂').join(' ');
    document.body.prepend(banner);


    // const bodyTopExtraPadding = document.createElement('div');
    // bodyTopExtraPadding.setAttribute('style', `height: ${document.querySelector('#edfbbf782c4142aa8b493971a2b06b67').offsetHeight + 'px'};`);
    // bodyTopExtraPadding.setAttribute('class', `pinMySize`);
    // document.body.prepend(bodyTopExtraPadding);
}, 100);
