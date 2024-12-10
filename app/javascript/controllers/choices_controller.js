import { Controller } from '@hotwired/stimulus'
import Choices from 'choices.js';

export default class extends Controller {
  static targets = ['select'];

  connect() {
    // console.log('ChoicesController connected', this, this.element);
    if (this.choices)
      return;
    
    this.choices = new Choices(this.selectTarget, {
      classNames: {
        containerOuter: ['choices'],
        placeholder: ['choices__placeholder', 'text-secondary'],
        itemSelectable: ['choices__item--selectable', 'text-secondary'],
      },
      removeItemButton: true,
    });
  }

  disconnect() {
    if (this.choices) {
      this.choices.destroy();
      this.choices = null;
    }
  }

  clearAllOptions() {
    if (this.choices)
      this.choices.clearChoices();
  }

  clearSelection(clearOptions = false) {
    if (this.choices) {
      // const values = [].concat(this.choices.getValue(true));
      // console.log('clearSelection', values, this.choices);
      // values.forEach(value => {
      //   this.choices.removeChoice(value);
      // });
      this.choices.removeActiveItems();

      if (clearOptions)
        this.clearAllOptions();
    }
  }
}
