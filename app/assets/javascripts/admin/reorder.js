$(function() {
  function bindReorderableLists() {
    $('ol.reorderable').each(function(index, element) {
      var container, freeAxis, nestable;
      container = $(element);
      nestable = container.hasClass('nestable');
      freeAxis = container.hasClass('free-axis');
      return container[nestable ? 'nested-sortable' : 'sortable']({
        handle: container.find('.mover').length ? '.mover' : 'div',
        items: 'li',
        placeholder: 'insertion-point',
        axis: nestable || freeAxis ? null : 'y',
        toleranceElement: '> div',
        update: function(event, ui) {
          $.ajax({
            url: typeof gUpdateOrderPath !== "undefined" && gUpdateOrderPath !== null ? gUpdateOrderPath : 'reorder',
            type: 'PUT',
            data: container.sortable('serialize'),
            dataType: 'html'
          }).done(function(data) {
            $.notify('L’ordre a été mis à jour', 'success');
          }).fail(function(data) {
            $.notify('L’ordre n’a pas pu être mis à jour (pensez à désactiver les bloqueurs de publicité)', 'error');
          });
        }
      });
    });
  }

  $(document).ready(function() {
    bindReorderableLists();
  });
});
