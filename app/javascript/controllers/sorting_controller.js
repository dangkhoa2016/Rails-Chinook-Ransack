import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = {
    model: String,
  };

  get liveFilterElement() {
    return this.element.querySelector('input.filter-field');
  }

  get sortingElements() {
    return this.element.querySelectorAll('.sort-columns .col [data-sort]');
  }

  get filterableElements() {
    const result = [];
    if (this.sortingElements.length) {
      this.sortingElements.forEach((element) => {
        if (element.dataset.direction === 'asc')
          result.push(element);
      });
    }

    return result;
  }

  connect() {
    if (this.liveFilterElement)
      this.liveFilterElement.addEventListener('keyup', this.handleKeyUpInput);

    /*
    if (this.sortingElements.length) {
      this.sortingElements.forEach((element) => {
        element.addEventListener('click', this.sort);
      });
    }
    */
  }

  handleKeyUpInput = (event) => {
    if (this.handleKeyUpInput.timeout) clearTimeout(this.handleKeyUpInput.timeout);

    this.handleKeyUpInput.timeout = setTimeout(() => {
      this.filterFields(event);
    }, 300);
  };

  filterFields(event) {
    const filterValue = event.target.value.toLowerCase();
    this.filterableElements.forEach((button) => {
      const row = button.closest('.col');
      
      if (filterValue) {
        const text = button.textContent.toLowerCase();
        if (text.includes(filterValue))
          row.classList.remove('d-none');
        else
          row.classList.add('d-none');
      } else
        row.classList.remove('d-none');
    });
  }

  sort = (event) => {
    if (!this.modelValue)
      return;

    const button = event.currentTarget;
    const column = button.dataset.sort;
    const direction = button.dataset.direction;

    if (button.classList.contains('btn-secondary'))
      return;
    
    this.sortingElements.forEach((element) => {
      element.classList.add('border-dashed', 'btn-outline-secondary');
      element.classList.remove('btn-secondary');
    });

    button.classList.add('btn-secondary');
    button.classList.remove('border-dashed', 'btn-outline-secondary');
    const sameGroupButton = button.parentElement.querySelector(`[data-sort="${column}"]:not([data-direction="${direction}"])`);
    if (sameGroupButton) {
      sameGroupButton.classList.add('btn-outline-secondary');
      sameGroupButton.classList.remove('border-dashed', 'btn-secondary');
    }

    const url = new URL(window.location.href);
    url.searchParams.set('sort', column);
    url.searchParams.set('direction', direction);
    url.searchParams.delete('page');
    url.searchParams.set('partial_only', true);

    fetch(url.toString(), {
      headers: {
        'Accept': 'text/html',
        'Content-Type': 'text/html'
      }
    }).then((response) => {
      return response.text();
    }).then((html) => {
      url.searchParams.delete('partial_only');
      window.history.pushState({}, '', url.toString());

      const parser = new DOMParser();
      const doc = parser.parseFromString(html, 'text/html');
      const newTable = doc.querySelector(`#${this.modelValue.toLowerCase()}`);
      if (!newTable)
        return;

      const oldTable = document.querySelector(`#${this.modelValue.toLowerCase()}`);
      oldTable.replaceWith(newTable);

    }).catch((error) => {
      console.log(`Failed to fetch: ${error}`);
    });
  }
}
