$(function() {
  $.notify.defaults({
    // whether to hide the notification on click
    clickToHide: true,
    // whether to auto-hide the notification
    autoHide: true,
    // if autoHide, hide after milliseconds
    autoHideDelay: 3000,
    // show the arrow pointing at the element
    arrowShow: true,
    // arrow size in pixels
    arrowSize: 5,
    // default positions
    elementPosition: 'top left',
    globalPosition: 'bottom right',
    // default style
    style: 'bootstrap',
    // default class (string or [string])
    className: 'success',
    // show animation
    showAnimation: 'slideDown',
    // show animation duration
    showDuration: 400,
    // hide animation
    hideAnimation: 'slideUp',
    // hide animation duration
    hideDuration: 200,
    // padding between element and notification
    gap: 2
  });
});
