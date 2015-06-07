$(document).ready(function(){
  function setBgInitial(){
    window_width = $(window).width();
    window_height = $(window).height();
  }
  setBgInitial();

  $('body').css('background-image', "url('https://dl.dropbox.com/s/x0ct1n7uurvykve/bg-1.jpg?dl=0')");

  function setBgSize(){
    if (window_width <= 767) {
      $('body').css('background-size', 'auto ' + (window_height + 200) + 'px');
    } else if (window_width > window_height){
      if ((2000 * window_width)/3008 < window_height){
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
});
