import { Controller } from '@hotwired/stimulus'
import Choices from 'choices.js';

export default class extends Controller {
  static values = {
    model: String,
  };
  static outlets = ['btn-remove'];

  get selectTarget() {
    return this.element.querySelector('select#filter-fields');
  }

  get formTarget() {
    return this.element.querySelector('form.advanced-form');
  }

  get loadingDiv() {
    if (this.formTarget)
      return this.formTarget.querySelector('.filter-holder > .loading');
  }

  get filterPanel() {
    return this.element.querySelector('#filter-panel');
  }

  get btnAddSelected() {
    if (this.filterPanel)
      return this.filterPanel.querySelector('.btn-add-selected');
  }

  get btnRemoveSelected() {
    if (this.filterPanel)
      return this.filterPanel.querySelector('.btn-remove-selected');
  }

  get clearFiltersButton() {
    if (this.formTarget)
      return this.formTarget.querySelector('.btn-clear-filters');
  }

  get clearInputsButton() {
    if (this.formTarget)
      return this.formTarget.querySelector('.btn-clear-inputs');
  }

  get selectedFilters() {
    if (this.formTarget)
      return this.formTarget.querySelectorAll('.filter-holder > [data-field-name]');
  }
  
  get filterLoadingDisplay() {
    if (this.loadingDiv)
      return this.loadingDiv.querySelector('.filter-name');
  }

  get filterActionDisplay() {
    if (this.loadingDiv)
      return this.loadingDiv.querySelector('.filter-action');
  }

  get progressDiv() {
    if (this.loadingDiv)
      return this.loadingDiv.querySelector('.spinner-border');
  }

  get cardDiv() {
    if (this.loadingDiv)
      return this.loadingDiv.querySelector('.card');
  }

  get closeLoadingButton() {
    if (this.loadingDiv)
      return this.loadingDiv.querySelector('.btn-close');
  }

  get formSelector() {
    if (this.modelValue)
      return `[data-filter-model-value='${this.modelValue}'] form`;
  }

  get templateController() {
    if (this.filterPanel) {
      const element = this.filterPanel.querySelector('.template-filters');
      return this.application.getControllerForElementAndIdentifier(element, 'choices');
    }
  }

  connect() {
    this.initEvents();
    console.log('FiltersController connected', this, this.element, this.choices);
    this.addTemplateChangeEvent();
    this.addFormSubmitEvent();
    this.initializeChoices();
    this.addEventHanleForButtons();
    
    // document.addEventListener('turbo:before-fetch-request', this.handleTurboBeforeFetchRequest);
    document.addEventListener('turbo:before-fetch-response', this.handleTurboBeforeFetchResponse);
    document.addEventListener('turbo:fetch-request-error', this.handleTurboRequestError);
  }

  disconnect() {
    // document.removeEventListener('turbo:before-fetch-request', this.handleTurboBeforeFetchRequest);
    document.removeEventListener('turbo:before-fetch-response', this.handleTurboBeforeFetchResponse);
    document.removeEventListener('turbo:fetch-request-error', this.handleTurboRequestError);

    if (this.choices) {
      this.choices.destroy();
      this.choices = null;
    }
  }

  addFormSubmitEvent() {
    if (this.formTarget) {
      this.formTarget.addEventListener('turbo:before-fetch-request', (event) => {
        event.preventDefault();
        console.log('Form submit event', event);

        let searchParams = event.detail.url.searchParams;
        
        searchParams = this.modifySearchParams(searchParams, ['created_at_between_from', 'created_at_between_to'], 'created_at_between');
        searchParams = this.modifySearchParams(searchParams, ['created_at_or_updated_at_between_from', 'created_at_or_updated_at_between_to'], 'created_at_or_updated_at_between');

        event.detail.url.search = searchParams.toString();
        event.detail.resume();
      });
    }
  }

  modifySearchParams(searchParams, keys_to_find, key_to_replace) {
    const entries = Array.from(searchParams.entries());
    // find the index of the key-value pair with key 'created_at_between_from'
    const indx = entries.findIndex(([key, value]) => keys_to_find.includes(key));
    
    const arrDates = [];
    const newEntries = [];
    entries.forEach(([key, value]) => {
      if (keys_to_find.includes(key)) {
        arrDates.push(value);
      } else {
        newEntries.push([key, value]);
      }
    });

    if (arrDates.length > 0)
      newEntries.splice(indx, 0, [key_to_replace, arrDates.join(',')]);

    return new URLSearchParams(newEntries);
  }

  addTemplateChangeEvent() {
    if (this.templateController) {
      const choices = this.templateController.choices;
      choices.passedElement.element.addEventListener('change', (event) => {
        const valueObject = choices.getValue();
        this.startLoadingFilter(`[${valueObject.label}] template`);
        const target = encodeURIComponent(`${this.formSelector} > .filter-holder > .loading`);
        const location = `/filters?template=${valueObject.value}&model=${this.modelValue}&target=${target}`;
        Turbo.visit(location, {
          acceptsStreamResponse: true
        });
      });
    }
  }

  initEvents() {
    // this.handleTurboBeforeFetchRequest = this.handleTurboBeforeFetchRequest.bind(this);
    this.handleTurboBeforeFetchResponse = this.handleTurboBeforeFetchResponse.bind(this);
    this.handleTurboRequestError = this.handleTurboRequestError.bind(this);
    this.clearFilters = this.clearFilters.bind(this);
    this.clearInputs = this.clearInputs.bind(this);
    this.handleSelectedChange = this.handleSelectedChange.bind(this);
  }

  addEventHanleForButtons() {
    /*
    if (this.clearFiltersButton)
      this.clearFiltersButton.addEventListener('click', this.clearFilters);

    if (this.clearInputsButton)
      this.clearInputsButton.addEventListener('click', this.clearInputs);
    */

    if (this.closeLoadingButton) {
      this.closeLoadingButton.addEventListener('click', (event) => {
        if (this.loadingDiv)
          this.loadingDiv.classList.add('d-none');
      });
    }
  }

  handleTurboRequestError(event) {
    console.log('turbo:fetch-request-error', event);
    if (!this.isFilterRequest(event.detail)) return;

    this.handleErrorLoad();
  }

  handleTurboBeforeFetchResponse(event) {
    console.log('turbo:before-fetch-response', event);

    if (!this.isFilterRequest(event.detail)) return;

    event.preventDefault();

    if (!event.detail.fetchResponse.succeeded) {
      this.handleErrorLoad();
      return;
    }

    if (this.loadingDiv)
      this.loadingDiv.classList.add('d-none');
    this.disabledSelectedOption();
  }

  handleErrorLoad() {
    if (this.progressDiv)
      this.progressDiv.classList.add('d-none');
    if (this.cardDiv)
      this.cardDiv.classList.add('border-danger');
    if (this.filterActionDisplay) {
      this.filterActionDisplay.textContent = 'Error load:';
      this.filterActionDisplay.classList.add('text-danger');
    }
    if (this.filterLoadingDisplay)
      this.filterLoadingDisplay.classList.add('text-danger');
    if (this.closeLoadingButton)
      this.closeLoadingButton.classList.remove('d-none');
    this.choices.refresh(null, false, true);
  }

  startLoadingFilter(filterName) {
    if (this.filterLoadingDisplay) {
      this.filterLoadingDisplay.textContent = filterName;
      this.filterLoadingDisplay.classList.remove('text-danger');
    }
    if (this.filterActionDisplay) {
      this.filterActionDisplay.textContent = 'Loading';
      this.filterActionDisplay.classList.remove('text-danger');
    }
    if (this.cardDiv)
      this.cardDiv.classList.remove('border-danger');
    if (this.progressDiv)
      this.progressDiv.classList.remove('d-none');
    if (this.loadingDiv)
      this.loadingDiv.classList.remove('d-none');
    if (this.closeLoadingButton)
      this.closeLoadingButton.classList.add('d-none');
  }

  /*
  handleTurboBeforeFetchRequest(event) {
    console.log('turbo:before-fetch-request', event);
    if (!this.isFilterRequest(event.detail)) return;
  }
  */

  isFilterRequest(detail) {
    if (detail.url) // fetch request
      return detail.url.pathname.includes('/filters');
    else if (detail.fetchResponse) // response
      return detail.fetchResponse.location.pathname.includes('/filters');
  }

  disabledSelectedOption() {
    if (!this.selectTarget)
      return;
    const selectOption = this.selectTarget.selectedOptions[0];
    if (selectOption) {
      selectOption.disabled = true;

      /*
      // special case
      switch (selectOption.value) {
        case 'created_at':
          var relatedOptions = this.selectTarget.querySelectorAll(`option[value='created_at_after'], option[value='created_at_before']`);
          if (relatedOptions.length > 0) {
            relatedOptions.forEach(option => {
              option.disabled = true;
            });
          }
          break;
        case 'updated_at':
          var relatedOptions = this.selectTarget.querySelectorAll(`option[value='updated_at_after'], option[value='updated_at_before']`);
          if (relatedOptions.length > 0) {
            relatedOptions.forEach(option => {
              option.disabled = true;
            });
          }
          break;
        case 'created_at_after':
        case 'created_at_before':
          var relatedOption = this.selectTarget.querySelector(`option[value='created_at']`);
          if (relatedOption) {
            relatedOption.disabled = true;
          }
          break;
        case 'updated_at_after':
        case 'updated_at_before':
          var relatedOption = this.selectTarget.querySelector(`option[value='updated_at']`);
          if (relatedOption) {
            relatedOption.disabled = true;
          }
          break;
      }
      */
    }

    this.choices.refresh(null, false, true);
  }

  handleSelectedChange(event) {
    /*
    // console.log('FiltersController change event', event);
    const selectOption = event.target.selectedOptions[0];
    this.startLoadingFilter(selectOption.textContent);
    // this.choices.refresh(null, false, true);

    const target = encodeURIComponent(`${this.formSelector} > .filter-holder > .loading`);
    const location = `/filters?name=${event.detail.value}&model=${this.modelValue}&target=${target}`;
    Turbo.visit(location, {
      acceptsStreamResponse: true
    });
    */

    if (event.target.selectedOptions.length === 0) {
      this.btnAddSelected.disabled = true;
      this.btnRemoveSelected.disabled = true;
    } else {
      this.btnAddSelected.removeAttribute('disabled');
      this.btnRemoveSelected.removeAttribute('disabled');
    }
  }

  initializeChoices() {
    if (this.choices) return;

    const controller = this;
    if (!controller.selectTarget)
      return;

    const selectedFilters = controller.selectedFilters;
    if (selectedFilters && selectedFilters.length > 0) {
      controller.selectedFilters.forEach(filter => {
        const value = filter.getAttribute('data-field-name');
        const option = controller.selectTarget.querySelector(`option[value='${value}']`);
        if (option)
          option.disabled = true;
      });
    }

    new Choices(controller.selectTarget, {
      classNames: {
        containerOuter: ['choices', 'mt-2'],
        placeholder: ['choices__placeholder', 'text-secondary'],
        itemSelectable: ['choices__item--selectable', 'text-secondary'],
      },
      removeItemButton: true,
      callbackOnInit: function () {
        controller.initializeChoicesCallback(this);
      },
    });
  }

  initializeChoicesCallback(choicesInstance) {
    choicesInstance.passedElement.element.addEventListener('change', this.handleSelectedChange);

    this.choices = choicesInstance;
  }

  clearFilters(event) {
    const btnRemoveOutlets = this.btnRemoveOutlets;
    if (!btnRemoveOutlets || btnRemoveOutlets.length === 0) return;

    btnRemoveOutlets.forEach(controller => {
      controller.removeElement(event);
    });
  }

  clearInputs(event) {
    const btnRemoveOutlets = this.btnRemoveOutlets;
    if (!btnRemoveOutlets || btnRemoveOutlets.length === 0) return;

    btnRemoveOutlets.forEach(controller => {
      controller.clearElementValue(event);
    });
  }
  
  addSelected(event) {
    const values = this.choices.getValue();
    this.startLoadingFilter(values.length > 1 ? `${values.length} filters` : `[${values[0].label}] filter`);
    const target = encodeURIComponent(`${this.formSelector} > .filter-holder > .loading`);
    const location = `/filters?name=${values.map(x => x.value).join(',')}&model=${this.modelValue}&target=${target}`;
    Turbo.visit(location, {
      acceptsStreamResponse: true
    });
  }

  removeSelected(event) {
    this.choices.removeActiveItems();
    this.btnAddSelected.setAttribute('disabled', true);
    this.btnRemoveSelected.setAttribute('disabled', true);
  }
}
