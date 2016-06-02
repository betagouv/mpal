function displayNewContactForm() {
  $('#nouveau-contact-modal')
    .modal({
      onApprove: function() {
        $('#new_contact').submit();          
        return false;
      }
    })
    .modal('show');
}
