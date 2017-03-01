$(function() {
  function bindSidebars() {
    var tabs = $('#sidebar-tabs');
    tabs.click(function(e) {
      $(this).tab('show');
      //NOTE: Bootstrap keeps all tabs active, maybe a bug
      $('#sidebar-tabs > a.active').removeClass('active');
    });
  }

  $(document).ready(function() {
    bindSidebars();
  });
});
