import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static values = {
    url: String,
  };

  get iconElement() {
    return this.element.querySelector('i.bi');
  }

  connect() {
    this.element.addEventListener('click', this.openOffcanvas.bind(this));
  }

  setLoadingIcon() {
    if (this.iconElement)
      this.iconElement.classList.add('spinner-border', 'rotate-icon');
  }

  removeLoadingIcon() {
    if (this.iconElement)
      this.iconElement.classList.remove('spinner-border', 'rotate-icon');
  }

  openOffcanvas = (event) => {
    if (this.element.hasAttribute('data-bs-toggle')) return;

    if (!this.urlValue) return;

    const elementId = this.element.getAttribute('aria-controls');
    if (!elementId) return;

    event.preventDefault();

    this.setLoadingIcon();

    fetch(this.urlValue)
      .then(response => response.text())
      .then(html => {
        this.removeLoadingIcon();

        const div = document.createElement('div');
        div.innerHTML = html;
        let offcanvas = div.querySelector(`#${elementId}`);
        if (!offcanvas) return;

        document.body.appendChild(offcanvas);

        offcanvas = document.querySelector(`#${elementId}`);
        if (!offcanvas) return;

        bootstrap.Offcanvas.getOrCreateInstance(offcanvas).show();
        this.element.setAttribute('data-bs-toggle', 'offcanvas');
      }).catch(error => {
        console.log('Error load offcanvas:', error);
        this.removeLoadingIcon();
      });
  };
}
