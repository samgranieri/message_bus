require 'message_bus'
require 'sinatra'
require 'sinatra/base'


class Chat < Sinatra::Base

  set :public_folder,  File.expand_path('../../../assets',__FILE__)

  use MessageBus::Rack::Middleware

  post '/message' do
    MessageBus.publish '/message', params

    "OK"
  end

  get '/' do

<<HTML

<html>
  <head>
    <script src="/jquery-1.8.2.js"></script>
    <script src="/message-bus.js"></script>
  </head>
  <body>
    <p>Chat Demo</p>
    <div id='messages'></div>
    <div id='panel'>
      <form>
        <textarea cols=80 rows=2></textarea>
      </form>
    </div>
    <div id='your-name'>Enter your name: <input type='text'/>

    <script>
      $(function() {
        var name;

        $('#messages, #panel').hide();

        $('#your-name input').keyup(function(e){
          if(e.keyCode == 13) {
            name = $(this).val();
            $('#your-name').hide();
            $('#messages, #panel').show();
          }
        });


        MessageBus.subscribe("/message", function(msg){
          $('#messages').append("<p>"+ msg.name + " said: " + msg.data + "</p>");
        }, 0); // last id is zero, so getting backlog


        $('textarea').keyup(function(e){
          if(e.keyCode == 13) {
            $.post("/message", { data: $('form textarea').val(), name: name} );
            $('textarea').val("");
          }
        });

      });
    </script>
  </body>
</html>

HTML
  end

  run! if app_file == $0
end
