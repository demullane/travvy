$(document).ready(function(){

	$(".gmap").sticky({ topSpacing: 0 });

	listingsContainer = $('div.container')[0];

	$(listingsContainer).css('padding-right', '0px');

	$('ul.tabs li').click(function(){
		var tab_id = $(this).attr('data-tab');

		$('ul.tabs li').removeClass('current');
		$('.tab-content').removeClass('current');

		$(this).addClass('current');
		$("#"+tab_id).addClass('current');

		if (tab_id === 'tab-1'){
			pinGridTab1();
		} else {
			pinGridTab2();
		}
	});

	function pinGridTab1(){
		$('#demo').pinterest_grid({
			no_columns: 1,
			padding_x: 10,
			padding_y: 10,
			margin_bottom: 0,
			single_column_breakpoint: 700
		});
	}

	pinGridTab1();

	function pinGridTab2(){
		$('#demo2').pinterest_grid({
			no_columns: 1,
			padding_x: 10,
			padding_y: 10,
			margin_bottom: 50,
			single_column_breakpoint: 700
		});
	}

	function columnPadding(){
		gridPs = $('p[id=pin-grid-text]');
		if ($(window).width() <= 991){
			$.each( gridPs, function(){
				$(this).css('padding-top', '10px');
			});
		} else {
			$.each( gridPs, function(){
				$(this).css('padding-top', '0px');
			});
		}
	}

	columnPadding();

	function mapHeight(){
		window_height = $(window).height();
		$('.gmap').css('height', window_height + 'px');
	}

	mapHeight();

	function hotelColumnHeight(){
		document_height = document.body.scrollHeight;
		$('#tab-1').css('height', document_height + 'px');
		$('#tab-2').css('height', document_height + 'px');
	}

	$(window).resize(function(){
		columnPadding();
		mapHeight();
	});

});
