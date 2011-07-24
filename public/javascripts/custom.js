// Custom Javascript

jQuery(document).ready(function() {
	
	// Secondary Navigation
	jQuery("ul.sf-menu").superfish({
		delay: 500,
		animation: {opacity:'show'},
		speed: 200,
		autoArrows: false,
		dropShadows: false
	}); 
	
	// Main Navigation
	jQuery('#nav ul.sf-menu').superfish({ 
		delay: 200,
		animation: {opacity:'show', height:'show'},
		speed: 'fast',
		autoArrows: false,
		dropShadows: false
	});
	
	// Coda Slider
	jQuery('#coda-slider-1').codaSlider({
		dynamicArrows: false,
		dynamicTabs: false,
		slideEaseDuration: 1000
	});
	jQuery(".loading").remove();

	// Post Grid Tooltips
	jQuery('.tooltip').poshytip({
		className: 'tip-twitter',
		showTimeout: 1,
		alignTo: 'target',
		alignX: 'center',
		offsetY: 5,
		allowTipHover: false,
		fade: false,
		slide: false
	});

	// Tab Widget
	jQuery(".tabs").tabs({ 
		fx: { opacity: 'toggle' } 
	});
	
	// Opacity change for clicked thumbnails
	jQuery('#slider_nav li a').click( 
		function () {
			jQuery('#slider_nav li a').css('opacity', 0.5);
			jQuery(this).css('opacity', 1);
		}
	);
	
	// Opacity change for hovered thumbnails
	jQuery('#slider_nav li a').hover( 
		function () {
			jQuery(this).not(".current").stop(true, true).animate({opacity: 1}, 300);
		}, function () {
			jQuery(this).not(".current").stop(true, true).animate({opacity: 0.5}, 300);
		}
	);
	
	// Input focus css change
	jQuery('input').focus( 
		function () {
			jQuery(this).css('border', '1px solid #d2d2d2');
			jQuery(this).css('colo	r', '#444444');
		}
	);
	
	// Input blur css change
	jQuery('input').blur( 
		function () {
			jQuery(this).css({
				border: '1px solid #e0e0e0',
				//color: '#999999'
			});
		}
	);
	
	// Submit buttons
	jQuery('#respond input.btn').hover( 
		function () {
			jQuery(this).css({background: '#fff'});
		}, function () {
			jQuery(this).css({background: 'url(/images/button_bg.gif) repeat-x'});
		}
	);

}); 
