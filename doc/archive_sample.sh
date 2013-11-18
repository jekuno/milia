# EDIT: app/assets/stylesheets/web-app-theme/basic.css
# correct around line 300, comment out the three lines below and
# add following instead
/*
.form .fieldWithErrors .error {
  color: red;
}
*/

.form input.text_field, .form textarea.text_area {
  width: 100%;
  border-width: 1px;
  border-style: solid;
}

.flash .message {
    -moz-border-radius: 3px;
    -webkit-border-radius: 3px;
    border-radius: 3px;
    text-align: center;
    margin: 0 auto 15px;
    color: white;
    text-shadow: 0 1px 0 rgba(0, 0, 0, 0.3);
  }
  .flash .message p {
    margin: 8px;
  }
  .flash .error, .flash .error-list, .flash .alert {
    border: 1px solid #993624;
    background: #cc4831 url("images/messages/error.png") no-repeat 10px center;
  }
  .flash .warning {
    border: 1px solid #bb9004;
    background: #f9c006 url("images/messages/warning.png") no-repeat 10px center;
  }
  .flash .notice {
    color: #28485e;
    text-shadow: 0 1px 0 rgba(255, 255, 255, 0.7);
    border: 1px solid #8a9daa;
    background: #b8d1e2 url("images/messages/notice.png") no-repeat 10px center;
  }
  .flash .error-list {
    text-align: left;
  }
  .flash .error-list h2 {
    font-size: 16px;
    text-align: center;
  }
  .flash .error-list ul {
    padding-left: 22px;
    line-height: 18px;
    list-style-type: square;
    margin-bottom: 15px;
  }

#<<<< EDIT <<<<<<<<<<<<<<<<<


