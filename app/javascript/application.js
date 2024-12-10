// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import '@hotwired/turbo-rails'
import 'controllers'
import '@popperjs/core'
import 'bootstrap'

Turbo.session.adapter.visitRequestFinished = function(visit) {
  // console.log("visitRequestFinished", this, visit);
  this.visitCompleted(visit);
}
