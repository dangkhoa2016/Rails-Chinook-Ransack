import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { model: String }

  connect() {
    
  }

  get fieldsContainer() {
    return this.element.querySelector('#fields-container');
  }

  get submitFormButton() {
    return this.element.querySelector('form [type="submit"]');
  }

  toggleButtonState() {
    if (!this.fieldsContainer)
      return;

    if (this.fieldsContainer.querySelectorAll('.form-control').length > 0)
      this.submitFormButton.removeAttribute('disabled');
    else
      this.submitFormButton.setAttribute('disabled', 'disabled');
  }

  addFields(event) {
    event.preventDefault();
    
    const fields = this.element.querySelector(`[data-controller='choices'] select`).selectedOptions;
    fetch('/tools/bulk_edit?fields=' + Array.from(fields).map(option => option.value).join(',') + '&model=' + this.modelValue)
      .then(response => {
        if (!response.ok) {
          console.log('fetch /tools/bulk_edit response', response);
          throw new Error('Network response was not ok');
        } else if (response.status !== 200) {
          console.log('fetch /tools/bulk_edit response', response);
          throw new Error(response);
        } else
          return response.text()
      })
      .then(html => {
        const parser = new DOMParser();
        const doc = parser.parseFromString(html, 'text/html');
        html = doc.querySelector('form').innerHTML;
        this.fieldsContainer.innerHTML = html;

        this.toggleButtonState();
      })
      .catch(error => {
        console.log('Error:', error);
        this.toggleButtonState();
      });
  }
}
