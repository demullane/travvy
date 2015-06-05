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
//= require_tree .

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

  function setBgInitial(){
    window_width = $(window).width();
    window_height = $(window).height();
  }
  setBgInitial();

  $('body').css('background-image', "url('https://dl.dropbox.com/s/0pqpplcl70mis0k/photo-1414924347000-9823c338079b.jpeg?dl=0')");

  function setBgSize(){
    if (window_width > window_height){
      if ((3744 * window_width)/5616 < window_height){
        $('body').css('background-size', 'auto ' + window_height + 'px');
      } else {
        $('body').css('background-size', window_width + 'px auto');
      }
    } else {
      $('body').css('background-size', 'auto ' + window_height + 'px');
    }
  }

  setBgSize();
  $(window).resize(function(){
    setBgInitial();
    setBgSize();
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

  $('#search-button').click(function(e) {
    $('#location_input').attr('disabled', false);
  });

  $('#search_form').validate({
    debug: false,
    errorPlacement: function(error, element) {
      element_id = element[0].id;
      error.appendTo('div#' + element_id + '_errors');
    },
    rules: {
      'location_input': {required: true},
      'arrival_date': {required: true, date: true, currentOrFutureDate: true},
      'departure_date': {required: true, date: true, laterThanArrivalDate: true},
      'guest_count': {required: true, digits: true}
    }
  });

});
