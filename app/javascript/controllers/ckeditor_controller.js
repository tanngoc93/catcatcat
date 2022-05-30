import { Controller } from "@hotwired/stimulus"

import ClassicEditor from "@ckeditor/ckeditor5-build-classic"

export default class extends Controller {
  connect() {

    const tagId = document.querySelector( "#ckeditor" )

    ClassicEditor.create( tagId, {
      language: {
        language: "en"
      },
      toolbar: [ "heading", "|", "bold", "italic", "link", "bulletedList", "numberedList", "blockQuote", "undo", "redo" ]
    })
    .then( editor => {
        window.editor = editor;
    } )
    .catch( error => {
      console.error( error );
    });
  }
}
