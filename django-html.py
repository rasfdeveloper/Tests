# Importa as classes e funções necessárias do Django.
from django.conf import settings
from django.urls import path
from django.http import HttpResponse
from django.core.management import execute_from_command_line
import sys

# Define a configuração mínima do Django.
# Isso configura o banco de dados e as URLs.
settings.configure(
    DEBUG=True,  # Ativa o modo de depuração para ver erros detalhados.
    ROOT_URLCONF=__name__, # Diz ao Django para usar este arquivo como o arquivo de URL principal.
    SECRET_KEY='sua-chave-secreta-aqui', # Uma chave de segurança necessária.
    ALLOWED_HOSTS=['*']
)

# Define a função da view que será renderizada.
# Esta função retorna uma resposta HTTP com o conteúdo HTML da página.
def homepage(request):
    """
    Renderiza a página inicial.
    """
    html_content = """
    <!DOCTYPE html>
    <html lang="pt-br">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Minha Aplicação Web Simples</title>
        <style>
            body {
                font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
                background-color: #f0f2f5;
                color: #333;
                display: flex;
                flex-direction: column;
                justify-content: center;
                align-items: center;
                height: 100vh;
                margin: 0;
                text-align: center;
            }
            .container {
                background-color: #ffffff;
                padding: 40px 60px;
                border-radius: 12px;
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            }
            h1 {
                color: #0056b3;
                margin-bottom: 20px;
            }
            p {
                font-size: 1.1em;
                line-height: 1.6;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Olá do seu Servidor Django!</h1>
            <p>Esta é uma página HTML simples servida por uma aplicação Django de um único arquivo.</p>
            <p>Se você está vendo esta página, significa que a sua aplicação está funcionando corretamente.</p>
        </div>
    </body>
    </html>
    """
    return HttpResponse(html_content)

# Define os padrões de URL.
# Neste caso, a URL raiz ("/") será mapeada para a função `homepage`.
urlpatterns = [
    path('', homepage),
]


if __name__ == '__main__':
    execute_from_command_line(sys.argv)


# python main.py runserver 0.0.0.0:8080
