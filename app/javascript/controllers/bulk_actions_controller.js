import { Controller } from '@hotwired/stimulus';
import SessionStorageService from '../session_storage_service';

export default class extends Controller {
  static values = {
    rootModel: String,
  };
  static targets = ['checkboxes', 'actionsList'];

  get displayCheckboxesElement() {
    return this.element.querySelector('#display-checkboxes');
  }

  //clear-checkboxes-on-page-change
  get clearCheckboxesOnPageChangeElement() {
    return this.element.querySelector('#clear-checkboxes-on-page-change');
  }

  get rootElement() {
    if (this.rootModelValue)
      return document.querySelector('#' + this.rootModelValue);
  }

  get selectedItemsCountElement() {
    return this.element.querySelector('#selected-items-count-sidebar');
  }

  get additionActionsCollapseElement() {
    return this.element.querySelector('#toggle-checkboxes');
  }

  get modalControllers() {
    return this.application.controllers.filter(controller => controller.identifier === 'modals');
  }


  connect() {
    this.initCheckboxesAction();
    this.initBulkActions();
  }

  initBulkActions() {
    if (!this.actionsListTarget)
      return;

    const buttons = this.actionsListTarget.querySelectorAll('.list-group-item-action');
    buttons.forEach(button => {
      button.addEventListener('click', this.handleBulkAction.bind(this));
    });

    // this.modalControllers
  }

  handleBulkAction(event) {
    const href = event.target.getAttribute('data-href');
    const ids = this.getSelectedIds();

    let additionalParams = '';
    if (ids.length === 0)
      additionalParams = location.search;
    else
      additionalParams = '?picked_ids=' + ids.join(',');

    event.target.setAttribute('href', href + additionalParams);
    this.modalControllers[0].handleTurboClickEvent(event);
  }

  initCheckboxesAction() {
    if (this.additionActionsCollapseElement) {
      this.additionActionsCollapse = new bootstrap.Collapse(this.additionActionsCollapseElement, {
        toggle: false
      });
    }

    if (this.displayCheckboxesElement) {
      this.displayCheckboxesElement.addEventListener('change', this.toggleCheckboxes.bind(this));

      const isChecked = SessionStorageService.getItem('displayCheckboxes');
      if (isChecked !== null) {
        this.displayCheckboxesElement.checked = isChecked;

        if (this.additionActionsCollapse) {
          if (isChecked) {
            this.additionActionsCollapse.show();
            this.setSelectedCountLabel();
          } else
            this.additionActionsCollapse.hide();
        }
      }
    }

    if (this.clearCheckboxesOnPageChangeElement) {
      this.clearCheckboxesOnPageChangeElement.addEventListener('change', this.clearCheckboxesOnPageChange.bind(this));

      const isChecked = SessionStorageService.getItem('clearCheckboxesOnPageChange');
      if (isChecked !== null)
        this.clearCheckboxesOnPageChangeElement.checked = isChecked;
    }

    if (this.selectedItemsCountElement)
      this.selectedItemsCountElement.addEventListener('click', this.showSelectedIds.bind(this));
  }

  showSelectedIds() {
    if (!this.selectedItemsCountElement)
      return;

    const pTag = this.selectedItemsCountElement.parentElement.querySelector('p');
    if (pTag)
      pTag.classList.toggle('d-none');
  }

  setSelectedCountLabel() {
    if (!this.selectedItemsCountElement)
      return;

    const ids = this.getSelectedIds();
    this.selectedItemsCountElement.textContent = ids.length;

    const pTag = this.selectedItemsCountElement.parentElement.querySelector('p');
    if (pTag)
      pTag.textContent = ids.join(', ');
  }

  toggleCheckboxes(event) {
    const isChecked = event.target.checked;

    document.dispatchEvent(new CustomEvent('app:toggle-checkboxes', {
      detail: {
        checked: isChecked
      }
    }));

    if (this.additionActionsCollapse) {
      if (isChecked)
        this.additionActionsCollapse.show();
      else
        this.additionActionsCollapse.hide();
    }

    SessionStorageService.setItem('displayCheckboxes', isChecked);

    if (!isChecked)
      SessionStorageService.setItem('clearCheckboxesOnPageChange', true);
  }

  clearCheckboxesOnPageChange(event) {
    SessionStorageService.setItem('clearCheckboxesOnPageChange', event.target.checked);
  }

  getSelectedIds() {
    const data = SessionStorageService.getItem('selectedIds') || {};
    if (!data)
      return [];

    if (!this.rootModelValue)
      return [];

    const firstKey = Object.keys(data)[0];
    if (firstKey !== this.rootModelValue) {
      SessionStorageService.removeItem('selectedIds');
      return [];
    }

    return data[this.rootModelValue] || [];
  }
}
