import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { model: String }

  connect() {
    
  }

  get fieldsContainer() {
    return this.element.querySelector('#fields-container');
  }

  addFields(event) {
    event.preventDefault();
    
    const fields = this.element.closest('form').querySelector(`[data-controller='choices'] select`).selectedOptions;
    fetch('/tools/bulk_edit?fields=' + Array.from(fields).map(option => option.value).join(',') + '&model=' + this.modelValue)
      .then(response => {
        if (!response.ok) {
          throw new Error('Network response was not ok');
        } else if (response.status !== 200) {
          throw new Error(response);
        } else
          return response.text()
      })
      .then(html => {
        const parser = new DOMParser();
        const doc = parser.parseFromString(html, 'text/html');
        html = doc.querySelector('form').innerHTML;
        this.fieldsContainer.innerHTML = html;
      })
      .catch(error => console.log('Error:', error));
  }
}
