$(function() {
  $.ajaxPrefilter(function(options, originalOptions, xhr) {
    if (!options.crossDomain) {
      var token = jQuery("meta[name='csrf-token']").attr("content");
      xhr.setRequestHeader('X-CSRF-Token', token);
    }
  });

  function bindDeleters() {
    $('#main').on('click', function(e) {
      var target = $(e.target);
      var deleter = target.closest('.js-deleter');
      if (!deleter.length) {
        return;
      }
      e.preventDefault();
      e.stopPropagation();
      if (confirm(deleter.attr('title'))) {
        $.ajax({
          type: 'POST',
          data: { _method: 'delete' },
          url: deleter.attr('href'),
          error: function() {
            $.notify('L’élément n’a pas pu être supprimé', 'error');
          },
          success: function() {
            $.notify('L’élément a été supprimé', 'success');
            $.ajax({
              url: window.location,
              type: 'GET',
              cache: false,
              success: function(data) {
                $('#main').html(data);
              }
            });
          }
        });
      }
    });
  }

  function bindExternalLinks() {
    $('a[rel*="external"]').attr('target', '_blank');
  }

  $(document).ready(function() {
    bindDeleters();
    bindExternalLinks();
    $('table.clickable tr').click(function() {
      window.location.href = $(this).attr('data-target');
    });
    $('*[data-show]').click(function() {
      $('#' + $(this).attr('data-show')).show().find('*[data-focus]').focus();
    });
    $('*[data-toggle]').click(function() {
      var elt = $('#' + $(this).attr('data-toggle'));
      if (elt.toggle().is(':visible'))
        elt.find('*[data-focus]').focus();
    });
  });
});
