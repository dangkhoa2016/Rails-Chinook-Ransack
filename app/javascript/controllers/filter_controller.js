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

  get filterPanel() {
    return this.element.querySelector('#filter-panel');
  }

  get noFiltersSelected() {
    return this.element.querySelector('.no-filters-selected');
  }

  get advancedFilterCollapse() {
    return this.element.querySelector('#advanced-filter');
  }

  get simpleFilterCollapse() {
    return this.element.querySelector('#simple-filter');
  }

  get toggleFilterCardsCollapse() {
    return this.advancedFilterCollapse.querySelector('#toggle-filter-cards');
  }

  get loadingDiv() {
    if (this.formTarget)
      return this.formTarget.querySelector('.filter-holder > .loading');
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
      return `[data-filter-model-value='${this.modelValue}'] form.advanced-form`;
  }

  get templateController() {
    if (this.filterPanel) {
      const element = this.filterPanel.querySelector('.template-filters');
      return this.application.getControllerForElementAndIdentifier(element, 'choices');
    }
  }

  connect() {
    this.initEvents();
    // console.log('FiltersController connected', this, this.element, this.choices);
    this.waitForTemplateControllerConnected(() => {
      this.addTemplateChangeEvent();
    });
    this.addEventHanleForCollapse();
    this.addFormSubmitEvent();
    this.initializeChoices();
    this.addEventHanleForButtons();

    this.toggleFilterCardsVisible();
    this.toggleAdvancedFilterVisible();
    
    // document.addEventListener('turbo:before-fetch-request', this.handleTurboBeforeFetchRequest);
    document.addEventListener('turbo:before-fetch-response', this.handleTurboBeforeFetchResponse);
    document.addEventListener('turbo:fetch-request-error', this.handleTurboRequestError);
    document.addEventListener('turbo:before-stream-render', this.handleBeforeStreamRender);
  }

  disconnect() {
    // document.removeEventListener('turbo:before-fetch-request', this.handleTurboBeforeFetchRequest);
    document.removeEventListener('turbo:before-fetch-response', this.handleTurboBeforeFetchResponse);
    document.removeEventListener('turbo:fetch-request-error', this.handleTurboRequestError);
    document.removeEventListener('turbo:before-stream-render', this.handleBeforeStreamRender);

    if (this.choices) {
      this.choices.destroy();
      this.choices = null;
    }
  }

  handleBeforeStreamRender(event) {
    // console.log('turbo:before-stream-render', event.target);
    const elements = event.target.templateContent.querySelectorAll('[data-field-name]');
    if (elements.length === 0)
      return;

    if (this.toggleFilterCardsCollapse && !this.toggleFilterCardsCollapse.classList.contains('show')) {
      const button = this.advancedFilterCollapse.querySelector(`[data-bs-target='#toggle-filter-cards']`);
      if (button)
        button.click();
    }

    elements.forEach(element => {
      const filter_name = element.getAttribute('data-field-name');
      let filter_element = this.formTarget.querySelector(`[data-field-name='${filter_name}']`);
      if (filter_element) {
        filter_element.remove();

        setTimeout(() => {
          filter_element = this.formTarget.querySelector(`[data-field-name='${filter_name}']`);
          // animated-border
          if (filter_element)
            this.animatedBorderForFilter(filter_element);
        }, 300);
      }
    });
  }

  addFormSubmitEvent() {
    if (this.formTarget) {
      this.formTarget.addEventListener('turbo:before-fetch-request', (event) => {
        event.preventDefault();
        // console.log('Form submit event', event);

        let searchParams = event.detail.url.searchParams;
        
        // searchParams = this.modifySearchParams(searchParams, ['created_at_between_from', 'created_at_between_to'], 'created_at_between');
        // searchParams = this.modifySearchParams(searchParams, ['updated_at_between_from', 'updated_at_between_to'], 'updated_at_between');
        // searchParams = this.modifySearchParams(searchParams, ['created_at_or_updated_at_between_from', 'created_at_or_updated_at_between_to'], 'created_at_or_updated_at_between');
        // searchParams = this.modifySearchParams(searchParams, ['number_of_tracks_between_from', 'number_of_tracks_between_to'], 'number_of_tracks_between');
        // searchParams = this.modifySearchParams(searchParams, ['number_of_invoices_between_from', 'number_of_invoices_between_to'], 'number_of_invoices_between');
        // searchParams = this.modifySearchParams(searchParams, ['number_of_invoice_lines_between_from', 'number_of_invoice_lines_between_to'], 'number_of_invoice_lines_between');
        // searchParams = this.modifySearchParams(searchParams, ['bytes_between_from', 'bytes_between_to'], 'bytes_between');
        // searchParams = this.modifySearchParams(searchParams, ['milliseconds_between_from', 'milliseconds_between_to'], 'milliseconds_between');
        // searchParams = this.modifySearchParams(searchParams, ['unit_price_between_from', 'unit_price_between_to'], 'unit_price_between');
        searchParams = this.modifySearchBetweenParams(searchParams);
        searchParams = this.modifySearchIDArrayParams(searchParams);
        event.detail.url.search = searchParams.toString();

        event.detail.resume();
      });
    }
  }

  waitForTemplateControllerConnected(callback, currentTry = 0, maxTries = 10) {
    if (currentTry >= maxTries) {
      console.log('waitForTemplateControllerConnected maxTries reached');
      return;
    }

    if (this.templateController) {
      callback();
    } else {
      setTimeout(() => {
        this.waitForTemplateControllerConnected(callback, currentTry + 1, maxTries);
      }, 50);
    }
  }

  hasBetweenKey(key, field) {
    return key.includes('_between_') && key.includes(field);
  }

  modifySearchBetweenParams(searchParams) {
    let entries = Array.from(searchParams.entries());

    const keys = ['created_at_or_updated_at_between', 'created_at_between', 'updated_at_between',
      'number_of_tracks_between', 'number_of_invoices_between', 'number_of_invoice_lines_between',
      'bytes_between', 'milliseconds_between', 'unit_price_between'];

    keys.forEach(field => {
      const indx = entries.findIndex(([key, value]) => this.hasBetweenKey(key, field));
      if (indx !== -1) {
        const arrDates = [];
        const newEntries = [];
        entries.forEach(([key, value]) => {
          if (this.hasBetweenKey(key, field))
            arrDates.push(value);
          else
            newEntries.push([key, value]);
        });

        if (arrDates.length > 0)
          newEntries.splice(indx, 0, [field, arrDates.join(',')]);

        entries = newEntries;
      }
    });

    return new URLSearchParams(entries);
  }

  modifySearchIDArrayParams(searchParams) {
    let found = true;
    let attempt = 0;
    while (found && attempt < 5) {
      var result = this.modifySearchArrayParams(searchParams, 'ids[]');
      if (result)
        searchParams = result;
      else
        found = false;

      attempt++;
    }

    return searchParams;
  }

  modifySearchArrayParams(searchParams, keys_to_find) {
    const entries = Array.from(searchParams.entries());

    const indx = entries.findIndex(([key, value]) => key.includes(keys_to_find));
    if (indx === -1)
      return false;

    const key_name = entries[indx][0];
    const key_to_replace = key_name.replace('[]', '');

    const arrIds = [];
    const newEntries = [];
    entries.forEach(([key, value]) => {
      if (key === key_name)
        arrIds.push(value);
      else
        newEntries.push([key, value]);
    });

    if (arrIds.length > 0)
      newEntries.splice(indx, 0, [key_to_replace, arrIds.join(',')]);

    return new URLSearchParams(newEntries);
  }

  modifySearchParams(searchParams, keys_to_find, key_to_replace) {
    const entries = Array.from(searchParams.entries());
    // find the index of the key-value pair with key 'created_at_between_from'
    const indx = entries.findIndex(([key, value]) => keys_to_find.includes(key));
    if (indx === -1)
      return searchParams;
    
    const arrDates = [];
    const newEntries = [];
    entries.forEach(([key, value]) => {
      if (keys_to_find.includes(key))
        arrDates.push(value);
      else
        newEntries.push([key, value]);
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
        if (valueObject.length === 0)
          return;

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
    this.handleBeforeStreamRender = this.handleBeforeStreamRender.bind(this);
  }

  toggleFilterCardsVisible(forceVisible = false) {
    if (this.toggleFilterCardsCollapse) {
      forceVisible = forceVisible || (this.application.filterCardsShow === true || this.application.filterCardsShow === undefined);
      if (forceVisible)
        this.toggleFilterCardsCollapse.classList.add('show');
      else
        this.toggleFilterCardsCollapse.classList.remove('show');
    }
  }

  toggleAdvancedFilterVisible(forceHidden = null) {
    if (!this.advancedFilterCollapse)
      return;
  
    if (typeof forceHidden === 'undefined' || forceHidden === null) {
      if (typeof this.application.advancedFilterShow === 'undefined' || this.application.advancedFilterShow === null)
        forceHidden = this.selectedFilters.length === 0;
      else
        forceHidden = this.application.advancedFilterShow === false;
    }

    if (forceHidden) {
      this.advancedFilterCollapse.classList.remove('show');
      this.simpleFilterCollapse.classList.add('show');
    } else {
      this.advancedFilterCollapse.classList.add('show');
      this.simpleFilterCollapse.classList.remove('show');

      if (this.noFiltersSelected && this.selectedFilters.length === 0)
        this.noFiltersSelected.classList.remove('d-none');
    }
  }

  addEventHanleForCollapse() {
    if (this.toggleFilterCardsCollapse) {
      this.toggleFilterCardsCollapse.addEventListener('show.bs.collapse', (event) => {
        this.application.filterCardsShow = true;
      });

      this.toggleFilterCardsCollapse.addEventListener('hide.bs.collapse', (event) => {
        this.application.filterCardsShow = false;
      });
    }

    if (this.advancedFilterCollapse) {
      this.advancedFilterCollapse.addEventListener('show.bs.collapse', (event) => {
        if (event.target !== this.advancedFilterCollapse)
          return;

        if (this.noFiltersSelected && this.selectedFilters.length === 0)
          this.noFiltersSelected.classList.remove('d-none');

        this.application.advancedFilterShow = true;
      });

      this.advancedFilterCollapse.addEventListener('hide.bs.collapse', (event) => {
        if (event.target !== this.advancedFilterCollapse)
          return;

        this.application.advancedFilterShow = false;
      });
    }
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

    if (this.btnRemoveOutlets.length > 0) {
      this.btnRemoveOutlets.forEach(controller => {
        controller.element.addEventListener('btn-remove:removed', (event) => {
          this.toggleFilterStatus(event.detail.value, false);
          this.choices.refresh();

          if (this.noFiltersSelected && this.selectedFilters.length === 0)
            this.noFiltersSelected.classList.remove('d-none');
        });
      });
    }
  }

  handleTurboRequestError(event) {
    console.log('turbo:fetch-request-error', event);
    if (!this.isFilterRequest(event.detail)) return;

    this.handleErrorLoad();
  }

  handleTurboBeforeFetchResponse(event) {
    // console.log('turbo:before-fetch-response', event);
    // this.toggleFilterCardsVisible();

    if (!this.isFilterRequest(event.detail)) return;

    event.preventDefault();

    if (this.noFiltersSelected)
      this.noFiltersSelected.classList.add('d-none');

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
    this.choices.refresh();
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
    if (selectOption)
      selectOption.disabled = true;

    this.choices.refresh();
  }

  handleSelectedChange(event) {
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
        controller.toggleFilterStatus(filter, true);
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

  toggleFilterStatus(element, disabled = true) {
    // console.log('toggleFilterStatus', element, disabled);
    const value = element.getAttribute('data-field-name');
    if (!value)
      return;

    const option = this.selectTarget.querySelector(`option[value='${value}']`);
    if (option)
      option.disabled = disabled;
  }

  clearFilters(event) {
    const btnRemoveOutlets = this.btnRemoveOutlets;
    if (!btnRemoveOutlets || btnRemoveOutlets.length === 0) return;

    btnRemoveOutlets.forEach(controller => {
      controller.removeElement(event);
    });

    if (this.noFiltersSelected)
      this.noFiltersSelected.classList.remove('d-none');
  }

  clearInputs(event) {
    const btnRemoveOutlets = this.btnRemoveOutlets;
    if (!btnRemoveOutlets || btnRemoveOutlets.length === 0) return;

    btnRemoveOutlets.forEach(controller => {
      controller.clearElementValue(event);
    });
  }

  animatedBorderForFilter(element) {
    const card = element.querySelector('.card');
    if (!card)
      return;

    card.classList.add('animated-border');
    setTimeout(() => {
      card.classList.remove('animated-border');
    }, 3000);
  }
  
  addSelected(event) {
    let selected = this.choices.getValue();
    // remove duplicated selected
    selected = selected.filter((item) => {
      const element = this.formTarget.querySelector(`[data-field-name='${item.value}']`);
      if (element) {
        this.animatedBorderForFilter(element);
        return false;
      }

      return true;
    });

    if (selected.length === 0)
      return;

    this.startLoadingFilter(selected.length > 1 ? `${selected.length} filters` : `[${selected[0].label}] filter`);
    // animated-border
    const target = encodeURIComponent(`${this.formSelector} > .filter-holder > .loading`);
    const location = `/filters?name=${selected.map(x => x.value).join(',')}&model=${this.modelValue}&target=${target}`;
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
