import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CalculadoraIMC(),
  ));
}

class CalculadoraIMC extends StatefulWidget {
  const CalculadoraIMC({super.key});

  @override
  State<CalculadoraIMC> createState() => _CalculadoraIMCState();
}

class _CalculadoraIMCState extends State<CalculadoraIMC> {
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
  String _genero = 'Masculino';
  double? _imc;
  String _textoResultado = '';

  // Função que detecta se o usuário digitou em cm (ex: 170) ou m (ex: 1.70).
  double? _parseAltura(String raw) {
    if (raw.trim().isEmpty) return null;
    final cleaned = raw.replaceAll(',', '.');
    final value = double.tryParse(cleaned);
    if (value == null) return null;
    // Se valor for maior que 3 (ex: 170), assumimos cm -> converte para metros
    if (value > 3) {
      return value / 100.0;
    }
    return value;
  }

  void _calcularIMC() {
    final peso = double.tryParse(_pesoController.text.replaceAll(',', '.'));
    final altura = _parseAltura(_alturaController.text);

    if (peso == null || altura == null || peso <= 0 || altura <= 0) {
      setState(() {
        _imc = null;
        _textoResultado = 'Por favor, informe peso e altura válidos.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha peso (kg) e altura (m ou cm) corretamente.')),
      );
      return;
    }

    final imc = peso / (altura * altura);

    final classificacao = _classificarIMC(imc, _genero);

    setState(() {
      _imc = imc;
      _textoResultado =
          'Gênero: $_genero\nIMC: ${imc.toStringAsFixed(2)}\n${classificacao.titulo}\n${classificacao.descricao}';
    });
  }

  // Classe simples para retornar título e descrição
  _CategoriaIMC _classificarIMC(double imc, String genero) {
    // As faixas seguem os valores padrão, mas as descrições podem variar por gênero
    if (imc < 16.0) {
      return _CategoriaIMC('Muito abaixo do peso', _mensagemDetalhe('Muito abaixo do peso', genero));
    } else if (imc < 18.5) {
      return _CategoriaIMC('Abaixo do peso', _mensagemDetalhe('Abaixo do peso', genero));
    } else if (imc < 25.0) {
      return _CategoriaIMC('Peso normal', _mensagemDetalhe('Peso normal', genero));
    } else if (imc < 30.0) {
      return _CategoriaIMC('Sobrepeso', _mensagemDetalhe('Sobrepeso', genero));
    } else if (imc < 35.0) {
      return _CategoriaIMC('Obesidade grau I', _mensagemDetalhe('Obesidade grau I', genero));
    } else if (imc < 40.0) {
      return _CategoriaIMC('Obesidade grau II', _mensagemDetalhe('Obesidade grau II', genero));
    } else {
      return _CategoriaIMC('Obesidade grau III (mórbida)', _mensagemDetalhe('Obesidade grau III (mórbida)', genero));
    }
  }

  // Mensagens diferentes por gênero (exemplo: tom das frases)
  String _mensagemDetalhe(String titulo, String genero) {
    // Você pode personalizar mais as mensagens por gênero aqui
    if (genero == 'Feminino') {
      switch (titulo) {
        case 'Muito abaixo do peso':
          return 'Muito abaixo do peso — procure orientação profissional.';
        case 'Abaixo do peso':
          return 'Abaixo do peso — avalie a alimentação e saúde.';
        case 'Peso normal':
          return 'Peso dentro da faixa considerada saudável.';
        case 'Sobrepeso':
          return 'Sobrepeso — pode haver risco aumentado para saúde.';
        case 'Obesidade grau I':
        case 'Obesidade grau II':
        case 'Obesidade grau III (mórbida)':
          return 'Obesidade — é recomendada avaliação médica e nutricional.';
        default:
          return '';
      }
    } else {
      // Masculino (padrão)
      switch (titulo) {
        case 'Muito abaixo do peso':
          return 'Muito abaixo do peso — atenção à saúde e à alimentação.';
        case 'Abaixo do peso':
          return 'Abaixo do peso — convém avaliar hábitos alimentares.';
        case 'Peso normal':
          return 'Peso dentro da faixa recomendada para boa saúde.';
        case 'Sobrepeso':
          return 'Sobrepeso — recomenda-se acompanhamento para controle do peso.';
        case 'Obesidade grau I':
        case 'Obesidade grau II':
        case 'Obesidade grau III (mórbida)':
          return 'Obesidade — procure acompanhamento médico e nutricional.';
        default:
          return '';
      }
    }
  }

  // Abre painel com todas as faixas e descrições (acionado pelo botão no canto da tela)
  void _mostrarTabelaIMC() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Faixas de IMC',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _faixaTile('Menos de 16', 'Muito abaixo do peso'),
                _faixaTile('16 · 16,0 – 18,4', 'Abaixo do peso'),
                _faixaTile('18,5 – 24,9', 'Peso normal'),
                _faixaTile('25,0 – 29,9', 'Sobrepeso'),
                _faixaTile('30,0 – 34,9', 'Obesidade grau I'),
                _faixaTile('35,0 – 39,9', 'Obesidade grau II'),
                _faixaTile('40 ou mais', 'Obesidade grau III (mórbida)'),
                const SizedBox(height: 12),
                const Text(
                  'Observação: IMC é um indicador simples e não substitui avaliação clínica completa.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _faixaTile(String faixa, String descricao) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              faixa,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: Text(descricao),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pesoController.dispose();
    _alturaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de IMC'),
        centerTitle: true,
        actions: [
          // Botão pequeno no canto direito
          IconButton(
            icon: const Icon(Icons.menu), // três riscos
            onPressed: _mostrarTabelaIMC,
            tooltip: 'Ver faixas do IMC',
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Gênero
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Selecione o gênero',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _genero = 'Masculino'),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _genero == 'Masculino' ? Colors.lightBlue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _genero == 'Masculino' ? Colors.blue : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/m.png', // imagem está na pasta assets
                          width: 70,
                          height: 70,
                        ),
                        const SizedBox(height: 6),
                        const Text('Masculino', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _genero = 'Feminino'),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _genero == 'Feminino' ? Colors.pink[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _genero == 'Feminino' ? Colors.pink : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/f.png', // imagem está na pasta assets
                          width: 70,
                          height: 70,
                        ),
                        const SizedBox(height: 6),
                        const Text('Feminino', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Peso
            TextField(
              controller: _pesoController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                // permite números, vírgula e ponto
                FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                LengthLimitingTextInputFormatter(5),
              ],
              decoration: const InputDecoration(
                labelText: 'Peso (kg)',
                border: OutlineInputBorder(),
                hintText: 'Ex: 70.5 ou 70,5',
              ),
            ),

            const SizedBox(height: 12),

            // Altura
            TextField(
              controller: _alturaController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')), // só números e ponto
                LengthLimitingTextInputFormatter(4),
              ],
              decoration: const InputDecoration(
                labelText: 'Altura (m ou cm)',
                border: OutlineInputBorder(),
                hintText: 'Ex: 1.75 ou 175',
              ),
            ),

            const SizedBox(height: 18),

            // Botão calcular
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calcularIMC,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent, // azul claro
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Calcular IMC',
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Resultado
            Card(
              elevation: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: _imc == null
                    ? Text(
                        _textoResultado.isEmpty ? 'Resultado' : _textoResultado,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'IMC: ${_imc!.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            // mostra só a linha da classificação (primeira linha de _textoResultado após IMC)
                            _textoResultado.split('\n').skip(2).take(1).join(),
                            style: const TextStyle(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _textoResultado.split('\n').skip(3).take(1).join(),
                            style: const TextStyle(fontSize: 14, color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Classe auxiliares
class _CategoriaIMC {
  final String titulo;
  final String descricao;

  _CategoriaIMC(this.titulo, this.descricao);
}
