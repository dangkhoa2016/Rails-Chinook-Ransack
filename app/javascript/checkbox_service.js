import SessionStorageService from './session_storage_service';

class CheckboxService {
  constructor(rootModelValue) {
    this.selectedIds = [];
    if (!rootModelValue) {
      const element = document.querySelector('[data-rails-controller]');
      if (element)
        rootModelValue = element.getAttribute('data-rails-controller');
    }

    this.rootModelValue = rootModelValue;

    this.init();
  }

  get rootElement() {
    if (this.rootModelValue)
      return document.querySelector('#' + this.rootModelValue);
  }

  get tableElement() {
    if (this.rootElement)
      return this.rootElement.querySelector('div > .table-responsive > table.table');
  }

  get cardListElement() {
    if (this.rootElement)
      return this.rootElement.querySelector('div > .card-list.row');
  }

  get selectedItemsCountElements() {
    return document.querySelectorAll('#selected-items-count, #selected-items-count-sidebar');
  }


  init() {
    this.handleLinkClick = this.handleLinkClick.bind(this);
    this.handleCheckboxChange = this.handleCheckboxChange.bind(this);
    this.handleAllCheckboxChange = this.handleAllCheckboxChange.bind(this);

    document.addEventListener('app:toggle-checkboxes', this.handleToggleCheckboxesChange.bind(this));

    let clearCheckboxesOnPageChange = SessionStorageService.getItem('clearCheckboxesOnPageChange');
    if (clearCheckboxesOnPageChange === null)
      clearCheckboxesOnPageChange = true;

    if (clearCheckboxesOnPageChange)
      SessionStorageService.removeItem('selectedIds');
    else
      this.selectedIds = this.getSelectedIds();
    
    const displayCheckboxes = SessionStorageService.getItem('displayCheckboxes');
    if (displayCheckboxes !== null)
      this.handleToggleCheckboxesChange({ detail: { checked: displayCheckboxes } });

    if (this.tableElement)
      this.setTHCheckboxState();

    this.setSelectedCountLabel();
  }

  setTHCheckboxState() {
    const checkboxes = this.tableElement.querySelectorAll('tbody td:nth-child(1) input[type="checkbox"]');
    if (!checkboxes.length)
      return;

    const toggleAllCheckbox = this.tableElement.querySelector(`thead th:nth-child(1) > input[name='${this.rootModelValue}_ids[]']`);
    if (!toggleAllCheckbox)
      return;

    const allChecked = Array.from(checkboxes).every(checkbox => checkbox.checked);
    if (allChecked) {
      toggleAllCheckbox.checked = true;
      toggleAllCheckbox.indeterminate = true;
      return;
    }

    const someChecked = Array.from(checkboxes).some(checkbox => checkbox.checked);
    if (someChecked) {
      toggleAllCheckbox.checked = false;
      toggleAllCheckbox.indeterminate = true;
    }
    else {
      toggleAllCheckbox.checked = false;
      toggleAllCheckbox.indeterminate = false;
    }
  }

  setSelectedCountLabel() {
    this.selectedItemsCountElements.forEach(element => {
      element.textContent = this.selectedIds.length;
    });
  }

  handleCheckboxChange(event) {
    if (event.target.checked && !this.selectedIds.includes(event.target.value))
      this.selectedIds.push(event.target.value);
    else {
      const index = this.selectedIds.indexOf(event.target.value);
      if (index > -1)
        this.selectedIds.splice(index, 1);
    }

    this.setSelectedCountLabel();
    this.setSelectedIds();

    if (event.target.parentElement.tagName == 'TD')
      this.setTHCheckboxState();
  }

  handleAllCheckboxChange(event) {
    if (!this.tableElement)
      return;

    const checkboxes = this.tableElement.querySelectorAll('tbody td:nth-child(1) input[type="checkbox"]');
    if (!checkboxes.length)
      return;

    const isChecked = event.target.indeterminate || event.target.checked;
    checkboxes.forEach(checkbox => {
      checkbox.checked = isChecked;
      if (isChecked) {
        if (!this.selectedIds.includes(checkbox.value))
          this.selectedIds.push(checkbox.value);
      } else {
        const index = this.selectedIds.indexOf(checkbox.value);
        if (index > -1) {
          this.selectedIds.splice(index, 1);
        }
      }
    });
    event.target.checked = isChecked;

    this.setSelectedCountLabel();
    this.setSelectedIds();
  }

  handleLinkClick(event) {
    event.preventDefault();
    const checkbox = event.target.parentElement.querySelector('input[type="checkbox"]');
    if (checkbox) {
      checkbox.checked = !checkbox.checked;
      checkbox.dispatchEvent(new Event('change'));
    }
  }

  removeCheckbox(element) {
    const checkbox = element.querySelector('input[type="checkbox"]');
    if (!checkbox)
      return;

    element.removeChild(checkbox);
    element.querySelector('a[href]').removeEventListener('click', this.handleLinkClick);
  }

  createCheckbox(element) {
    const checkbox = document.createElement('input');
    checkbox.type = 'checkbox';
    checkbox.classList.add('form-check-input', 'me-1');

    const id = element.parentElement.getAttribute('id');

    checkbox.name = 'ids[]';
    checkbox.value = id ? id.split('_').pop() : '';
    checkbox.checked = this.selectedIds.includes(checkbox.value);

    // Insert the checkbox
    if (element.firstChild)
      element.insertBefore(checkbox, element.firstChild);
    else
      element.appendChild(checkbox);
  
    // Attach event listeners
    element.querySelector('a[href]').addEventListener('click', this.handleLinkClick);
  
    return checkbox;
  }
  
  addCheckboxToCard(element) {
    const checkbox = this.createCheckbox(element, false);
    checkbox.addEventListener('change', this.handleCheckboxChange);
  }
  
  addCheckboxToRow(element) {
    const checkbox = this.createCheckbox(element, true);
    if (element.tagName === 'TH') {
      checkbox.addEventListener('change', this.handleAllCheckboxChange);
      checkbox.setAttribute('name', `${this.rootModelValue}_ids[]`);
    } else 
      checkbox.addEventListener('change', this.handleCheckboxChange);
  }
  
  handleTableRows(list, checked) {
    var items = list.querySelectorAll('tbody > tr > td:first-child');
    if (!items || items.length == 0)
      return;

    if (checked) {
      this.addCheckboxToRow(list.querySelector('thead > tr:last-child > th:first-child'));
      items.forEach(item => {
        this.addCheckboxToRow(item);
      });
    } else {
      this.removeCheckbox(list.querySelector('thead > tr:last-child > th:first-child'));
      items.forEach(item => {
        this.removeCheckbox(item);
      });
    }
  }

  handleCardList(list, checked) {
    var items = list.querySelectorAll('.card-header');
    if (!items || items.length == 0)
      return;

    if (checked) {
      items.forEach(item => {
        this.addCheckboxToCard(item);
      });
    } else {
      items.forEach(item => {
        this.removeCheckbox(item);
      });
    }
  }

  createSelectedItemInformation() {
    const div = document.createElement('div');
    div.setAttribute('role', 'alert');
    div.classList.add('alert', 'alert-info', 'mb-3');
    div.innerHTML = '<strong>Selected items:</strong> <span id="selected-items-count">0</span>';
    return div;
  }

  handleToggleCheckboxesChange(event) {
    if (!this.rootElement)
      return;

    const isChecked = event?.detail?.checked;

    if (isChecked) {
      if (!this.selectedItemInformationElement)
        this.selectedItemInformationElement = this.createSelectedItemInformation();

      this.rootElement.insertBefore(this.selectedItemInformationElement, this.rootElement.firstChild);
    } else {
      if (this.selectedItemInformationElement)
        this.selectedItemInformationElement.classList.add('d-none');
    }

    let list = this.tableElement;
    if (list)
      this.handleTableRows(list, isChecked);
    else {
      list = this.cardListElement;
      if (!list)
        return;
      this.handleCardList(list, isChecked);
    }
  }
  
  getSelectedIds() {
    const data = SessionStorageService.getItem('selectedIds') || {};
    if (!data || !this.rootModelValue)
      return [];

    const firstKey = Object.keys(data)[0];
    if (firstKey !== this.rootModelValue) {
      SessionStorageService.removeItem('selectedIds');
      return [];
    }

    return data[this.rootModelValue] || [];
  }

  setSelectedIds() {
    if (!this.rootModelValue)
      return;

    SessionStorageService.setItem('selectedIds', {
      [this.rootModelValue]: this.selectedIds
    });
  }
}

export default CheckboxService;
