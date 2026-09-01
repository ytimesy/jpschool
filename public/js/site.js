document.addEventListener('DOMContentLoaded', function(){
  // stop other audios when one plays
  const audios = Array.from(document.querySelectorAll('audio'));
  audios.forEach(a => {
    a.addEventListener('play', () => {
      audios.forEach(o => { if(o !== a) o.pause(); });
    });
  });
});
