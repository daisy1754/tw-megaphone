// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
Rails.start();
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

import jquery, { type } from 'jquery';
window.$ = window.jquery = jquery;

import 'bootstrap'

import '@fortawesome/fontawesome-free/js/all'
import '../src/application.scss'

function hideAndShow(toHideSelector, toShowSelector) {
  $(toHideSelector).hide();
  $(toShowSelector).show();
}

function pollForRerankProgress() {
  hideAndShow(".followers", ".load-follower-spinner");
  Rails.ajax({
    url: `/followers/ranking_progress`,
    type: "get",
    success: function(progress) {
      if (progress.num_followers === progress.num_followers_with_latest_score) {
        Rails.ajax({
          url: `/followers/list`,
          type: "get",
          success: function(response) {
            const container = $(".followers");
            container.empty();
            for (let i = 0; i < response.followers.length; i++) {
              const f = response.followers[i];
              container.append($(`
                <div class="media text-muted pt-3">
                  <img src="${f.image_url}" data-holder-rendered="true" class="mr-2 rounded follower-icon" >
                  <div class="media-body pb-3 mb-0 small lh-125 border-bottom border-gray">
                    <div class="d-flex justify-content-between align-items-center w-100">
                      <strong class="text-gray-dark">${f.name}</strong>
                      <span>Score: ${f.score}</span>
                    </div>
                    <span class="d-block">@${f.screen_name}</span>
                  </div>
                </div>`));
            }
          },
          error: function(e) {
            console.error(e);
          }
        });
        $(".followers").show();
        $(".load-follower-spinner").hide();
      } else {
        const progressText = progress.num_followers_with_latest_score > 0 ? ` (${progress.num_followers_with_latest_score} / ${progress.num_followers})` : "";
        const text = `reordering your followers${progressText}...`;
        $(".rerank-progress").text(text);
        setTimeout(pollForRerankProgress, 1000);
      }
    },
    error: function(e) {
      console.error(e);
    }
  });
}

function pollForFolloweSync() {
  Rails.ajax({
    url: `/followers/sync_progress`,
    type: "get",
    success: function(response) {
      console.log(response);
      if (response.completed) {
        location.reload();
      } else {
        let progressText = "";
        if (response.num_all_followers && response.num_all_followers > 0 && response.num_synced > 0) {
          progressText = ` (${response.num_synced} / ${response.num_all_followers })`
        }
        const text = `Downloading your follower list from Twitter${progressText}...\n
          If you have many followers, please come back later. We can only sync 20K accounts per hour`;
        $(".sync-follower-progress").text(text);
        setTimeout(pollForFolloweSync, 1000);
      }
    },
    error: function(e) {
      console.error(e);
    }
  });
}

$(document).ready(function() {
  $(document).on("change", ".rule-select", function() {
    const container = $(".rule-details-input-area");
    container.empty();

    const type = $(this).children("option:selected").attr("data-type");
    if (type === "placeholder") {
      console.log("ignore click for placeholder");
      return;
    }

    const description = $(this).children("option:selected").attr("data-description");
    const element = `<div>${description}</div>`
      .replace("$score", "<input class='form-control new-rule-score' type='number'></input> points ")
      .replace("$value", "<input class='form-control new-rule-value'></input>");
    container.append($(element));
  });

  $(document).on("click", ".delete-rule", function() {
    const rowToRemove = $(this).closest(".rule-item");
    Rails.ajax({
      url: `/rules/${$(this).attr("data-item-id")}`,
      type: "delete",
      success: function(rule) {
        rowToRemove.remove();
        pollForRerankProgress();
      },
      error: function(e) {
        console.error(e);
      }
    });
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
    if (type === "placeholder") {
      console.log("ignore click for placeholder");
      return;
    }
    const score = ($(".new-rule-score").val() || "").trim();
    const value = ($(".new-rule-value").val() || "").trim();
    let description = $(".rule-select").children("option:selected").attr("data-description");
    description = description.replace("$score", `${score} points`).replace("$value", value);
    $(".add-rule-modal-body-footer").hide();
    $(".add-rule-modal-loading").show();
    const params = {
      type,
      description,
      score,
      value
    };
    Rails.ajax({
      url: "/rules",
      type: "post",
      data: new URLSearchParams(params).toString(),
      success: function(rule) {
        $(".add-rule-modal-body-footer").show();
        $(".add-rule-modal-loading").hide();
        window.$("#addRuleModal").modal("hide");
        $(".rule-group").append($(`<li class='list-group-item d-flex justify-content-between align-items-center w-100 rule-item'>
        <span>${description}</span>
          <i class="fa fa-trash text-muted delete-rule delete-icon" data-item-id="${rule.id}"></i>
        </li>`));
        pollForRerankProgress();
      },
      error: function(e) {
        console.error(e);
        $(".add-rule-modal-body-footer").show();
        $(".add-rule-modal-loading").hide();
      }
    });
  });

  if (location.pathname === "/followers") {
    if ($(".followers").length > 0) {
      pollForRerankProgress();
    } else {
      pollForFolloweSync();
    }
  }

  /* -- dms/new --- */
  $(document).on("click", ".send-dm-confirm-btn", function() {
    hideAndShow(".submit-confirm", ".confirm-spinner");
    $(".cancel-btn").hide();
    const params = {
      text: $(".dm-text-area").val()
    };
    Rails.ajax({
      url: "/dms",
      type: "post",
      data: new URLSearchParams(params).toString(),
      success: function(response) {
        console.log(response);
        location.href = `/dms/${response.id}`;
      },
      error: function(e) {
        console.error(e);
      }
    });
  });
  $(".send-test-dm").click(function() {
    $(".send-test-dm-spinner").show();
    $(".send-test-dm-text").hide();
    const params = {
      text: $(".dm-text-area").val()
    };
    Rails.ajax({
      url: "/dms/send_me",
      type: "post",
      data: new URLSearchParams(params).toString(),
      success: function(response) {
        console.log(response);
        console.log(response.sent);
        if (response.sent) {
          $(".toast-body").text("message sent successfully");
          window.jquery(".toast").toast('show');
        } else if (response.rate_limit) {
          $(".toast-body").text("failed to send message - API rate limit");
          window.jquery(".toast").toast('show')
        }
        $(".send-test-dm-spinner").hide();
        $(".send-test-dm-text").show();
      },
      error: function(e) {
        console.error(e);
        $(".toast-body").text("failed to send message");
        window.jquery(".toast").toast('show')
        $(".send-test-dm-spinner").hide();
        $(".send-test-dm-text").show();
      }
    });
  });

  /* -- dms/show --- */
  function exportData(type) {
    hideAndShow(`.export-${type}-text`, `.export-${type}-spinner`);
    const params = {
      type: type,
    };
    Rails.ajax({
      url: "/followers/export",
      type: "post",
      data: new URLSearchParams(params).toString(),
      success: function(response) {
        location.href = `/exports/${response.id}`;
      },
      error: function(e) {
        console.error(e);
      }
    });
  }
  $(".export-full").click(function() {
    exportData("full");
  });
  $(".export-email").click(function() {
    exportData("email");
  });
  
  /* -- email optin --*/
  $(".submit-email").click(function() {
    hideAndShow(".submit-email-text", ".submit-email-spinner");
    $(".error-msg").hide();
    const split = location.pathname.split("/");
    const params = {
      email: $("#email").val(),
      slug: split[split.length - 1]
    };
    Rails.ajax({
      url: `/emails/${params.slug}/save`,
      type: "post",
      data: new URLSearchParams(params).toString(),
      success: function(response) {
        console.log(response);
        hideAndShow(".form-wrapper", ".thank-you");
      },
      error: function(e) {
        console.error(e);
        $(".error-msg").text("failed to save");
        $(".error-msg").show();
        hideAndShow(".submit-email-spinner", ".submit-email-text");
      }
    });
  });

  if (location.pathname.indexOf("/exports/") === 0) {
    function pollForExport() {
      const id = location.pathname.substring("/exports/".length);
      Rails.ajax({
        url: `/exports/${id}/status`,
        type: "get",
        success: function(response) {
          console.log(response);
          if (response.completed) {
            $(".export-progress").text("");
            location.href = response.download_url;
          } else if (response.current > 0) {
            $(".export-progress").text(`processed ${response.current} followers out of ${response.total}...`);
            setTimeout(pollForExport, 2000);
          } else {
            setTimeout(pollForExport, 2000);
          }
        },
        error: function(e) {
          console.error(e);
          setTimeout(pollForExport, 2000);
        }
      });
    }
    pollForExport();
  }
});