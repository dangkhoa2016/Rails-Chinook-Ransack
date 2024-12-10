import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = {
    elementToRemove: String,
  };

  get rootElement() {
    return this.element.closest(this.elementToRemoveValue);
  }

  connect() {
    // console.log('BtnRemoveController connected', this, this.element);
    this.element.classList.add('btn-remove-filter', 'position-absolute');
    this.element.addEventListener('click', this.removeElement.bind(this));
  }

  removeElement(event) {
    console.log('BtnRemoveController removeFilter', event);
    if (!this.elementToRemoveValue) {
      return;
    }

    if (this.rootElement) {
      this.rootElement.remove();
    }
  }

  clearElementValue() {
    const inputs = this.rootElement.querySelectorAll('input, select');
    inputs.forEach((input) => {
      if (input.tagName === 'INPUT') {
        input.value = '';
      } else if (input.tagName === 'SELECT') {
        input.selectedIndex = 0;
      }
    });
  }
}
