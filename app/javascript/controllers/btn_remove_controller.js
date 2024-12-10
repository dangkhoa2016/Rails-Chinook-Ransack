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
    // console.log('BtnRemoveController removeFilter', event);
    if (!this.elementToRemoveValue) {
      return;
    }

    if (this.rootElement) {
      this.rootElement.remove();

      this.element.dispatchEvent(new CustomEvent('btn-remove:removed', {
        detail: { value: this.rootElement },
        bubbles: false,
        composed: true
      }));
    }
  }

  clearElementValue() {
    const inputs = this.rootElement.querySelectorAll('input, select');
    inputs.forEach((input) => {
      if (input.tagName === 'INPUT') {
        input.value = '';
      } else if (input.tagName === 'SELECT') {
        if (input.getAttribute('data-choice') === 'active') {
          const controllerName = input.closest('[data-controller]').getAttribute('data-controller');
          const controller = this.application.getControllerForElementAndIdentifier(input.closest('[data-controller]'), controllerName);
          controller.clearSelection();
        } else
          input.selectedIndex = -1;
      }
    });
  }
}
