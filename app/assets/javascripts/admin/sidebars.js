$(function() {
  function bindSidebars() {
    var tabs = $('#sidebar-tabs')
    tabs.click(function(e) {
      var element = $(e.target);
      var link = element.closest('a.list-group-item');
      var active = $('#sidebar-tabs > a.active').toggleClass('active');
      link.addClass('active');
    });
  }

  $(document).ready(function() {
    bindSidebars();
  });
});
