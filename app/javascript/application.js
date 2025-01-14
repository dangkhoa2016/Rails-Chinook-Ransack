// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import '@hotwired/turbo-rails'
import 'controllers'
import '@popperjs/core'
import 'bootstrap'
import CheckboxService from './checkbox_service'

Turbo.session.adapter.visitRequestFinished = function(visit) {
  // console.log("visitRequestFinished", this, visit);
  this.visitCompleted(visit);
}

const app = () => {
  console.log('Rails-Chinook-Ransack is running at', new Date().toLocaleTimeString());
  new CheckboxService();
};

addEventListener('turbo:load', () => {
  app();
});
