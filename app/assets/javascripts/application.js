// Minimal local manifest until Stimulus/Turbo are fully wired.
document.addEventListener("click", (event) => {
  const button = event.target.closest("[data-audio-speed]");
  if (!button) return;

  const audioBox = button.closest(".audio-box");
  const audio = audioBox && audioBox.querySelector("audio");
  if (!audio) return;

  audio.playbackRate = Number(button.dataset.audioSpeed);
  audioBox.querySelectorAll("[data-audio-speed]").forEach((speedButton) => {
    speedButton.classList.toggle("active", speedButton === button);
  });
});
