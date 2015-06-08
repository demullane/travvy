$(document).ready(function(){
  function setBgInitial(){
    window_width = $(window).width();
    document_height = document.body.scrollHeight;
  }
  setBgInitial();

  $('body').css('background-image', "url('https://dl.dropbox.com/s/x0ct1n7uurvykve/bg-1.jpg?dl=0')");

  function setBgSize(){
    if (window_width > document_height){
      if ((2000 * window_width)/3008 < document_height){
        $('body').css('background-size', 'auto ' + document_height + 'px');
      } else {
        $('body').css('background-size', window_width + 'px auto');
      }
    } else {
      $('body').css('background-size', 'auto ' + document_height + 'px');
    }
  }

  setBgSize();
  $(window).resize(function(){
    setBgInitial();
    setBgSize();
  });
});
