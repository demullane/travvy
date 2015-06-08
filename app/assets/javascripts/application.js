//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require moment
//= require bootstrap-datetimepicker
//= require underscore
//= require gmaps/google
//= require jquery.validate
//= require jquery.validate.additional-methods
//= require turbolinks

// Remove '#_=_' from end of URL after Facebook login
if ( (location.hash == "#_=_" || location.href.slice(-1) == "#_=_") ) {
    removeHash();
}

function removeHash() {
    var scrollV, scrollH, loc = window.location;
    if ('replaceState' in history) {
        history.replaceState('', document.title, loc.pathname + loc.search);
    } else {
        // Prevent scrolling by storing the page's current scroll offset
        scrollV = document.body.scrollTop;
        scrollH = document.body.scrollLeft;

        loc.hash = '';

        // Restore the scroll offset, should be flicker free
        document.body.scrollTop = scrollV;
        document.body.scrollLeft = scrollH;
    }
}

$(document).ready(function() {

  $('select').change(function() {
    if ($(this).children('option:first-child').is(':selected')) {
      $(this).addClass('placeholder');
    } else {
      $(this).removeClass('placeholder');
    }
  });

  $('#location_input').change(function(event, ui) {
    var results = $('.pac-item').map(function() {
      return $(this).children().map(function() {
        return $(this).text();
      }).get().join(' ');
    }).get();
    var searchText = $('#location_input').val();
    setTimeout(function() {
      if (_.contains(results, searchText)) {
        $('#location_input').attr('disabled', true);
      } else {
        $('#location_input').val('');
        $('#location_input').attr('placeholder','Select from autocomplete dropdown');
        $('#location_input').attr('disabled', false);
      }
    }, 0);
  });

  $('#guest-btn').click(function() {
    open($('#guest-select'));
  });

  $('#filter-btn').click(function() {
    open($('#filter-select'));
  });

  function open(elem) {
    if (document.createEvent) {
        var e = document.createEvent('MouseEvents');
        e.initMouseEvent('mousedown', true, true, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null);
        elem[0].dispatchEvent(e);
    } else if (element.fireEvent) {
        elem[0].fireEvent('onmousedown');
    }
  }

  $('#search-button').click(function(e) {
    $('#location_input').attr('disabled', false);
  });

  $('#search_form').validate({
    debug: false,
    errorPlacement: function(error, element) {
      element_id = element[0].id;
      if (element_id === 'guest-select'){
        error.appendTo('div#guest_count_errors');
      } else if (element_id === 'filter-select'){
        error.appendTo('div#search_filter_errors');
      } else{
        error.appendTo('div#' + element_id + '_errors');
      }
    },
    rules: {
      'location_input': {required: true},
      'arrival_date': {required: true, date: true, currentOrFutureDate: true},
      'departure_date': {required: true, date: true, laterThanArrivalDate: true},
      'guest_count': {required: true, digits: true}
    }
  });

});
