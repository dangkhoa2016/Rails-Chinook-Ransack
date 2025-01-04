import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect() {
    this.element.addEventListener('change', this.changePageSize.bind(this));
  }

  changePageSize(event) {
    const pageSize = event.target.value;
    const url = new URL(window.location.href);
    const perPageParam = this.element.getAttribute('name') || 'per_page';
    url.searchParams.set(perPageParam, pageSize);
    url.searchParams.delete('page');
    // window.location.href = url.toString();
    Turbo.visit(url.toString());
  }
}
