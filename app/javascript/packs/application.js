// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

import jquery from 'jquery';
window.$ = window.jquery = jquery;

import 'bootstrap'
import '@fortawesome/fontawesome-free/js/all'
import '../src/application.scss'

$(document).ready(function() {
  $(".rule-select").change(function() {
    const container = $(".rule-details-input-area");
    container.empty();

    const description = $(this).children("option:selected").attr("data-description");
    const element = `<div>${description}</div>`
      .replace("$score", "<input class='form-control new-rule-score'></input> points ")
      .replace("$value", "<input class='form-control new-rule-value'></input>");
    container.append($(element));
  });

  $(".delete-rule").click(function() {
    console.log($(this).attr("data-item-id")); // TODO ajax call to delete this
    $(this).closest(".rule-item").remove();
  });

  $(".add-rule-confirm").click(function() {
    if ($(".new-rule-score").length > 0 && !$(".new-rule-score").val()) {
      console.log("invalid score");
      return;
    }
    if ($(".new-rule-value").length > 0 && !$(".new-rule-value").val()) {
      console.log("invalid value");
      return;
    }
    const type = $(".rule-select").children("option:selected").attr("data-type");
    let description = $(".rule-select").children("option:selected").attr("data-description");
    const score = ($(".new-rule-score").val() || "").trim();
    const value = ($(".new-rule-value").val() || "").trim();
    description = description.replace("$score", score).replace("$value", value);
    console.log(description);
    $(".rule-group").append($(`<li class='list-group-item d-flex justify-content-between align-items-center w-100 rule-item'>
      <span>${description}</span>
        <i class="fa fa-trash text-muted delete-rule"></i>
      </li>`)); // TODO add id based on server response
    window.$("#addRuleModal").modal("hide");
  });
});