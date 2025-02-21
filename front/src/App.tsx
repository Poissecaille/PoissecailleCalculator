import React, { useState } from 'react';
import { Calculator, RotateCcw, Delete } from 'lucide-react';
import { evaluateExpression } from './api';
import { CalculatorState } from './utils/types';
import { isOperator } from './utils/functions';
// Store useless here we can keep the component state inside the component itself for a small project
const initialState: CalculatorState = {
  display: '',
  currentNumber: '',
};

const buttons = [
  ['7', '8', '9', '÷'],
  ['4', '5', '6', '×'],
  ['1', '2', '3', '-'],
  ['0', '.', '=', '+'],
];

const App = () => {
  const [state, setState] = useState<CalculatorState>(initialState);
  const [error, setError] = useState<string | null>(null);
  // const [loading, setLoading] = useState(false);


  const handleButtonClick = async (value: string) => {
    if (value === '=' && state.display && state.currentNumber) {
      const expression = `${state.currentNumber} ${state.display}`;
      console.log("--------------------")
      console.log(expression)
      console.log("--------------------")

      try {
        const response = await evaluateExpression(expression);

        if (response.code > 201) {
          setError(error);
        } else {
          setState({
            display: response.data!.toString(),
            currentNumber: '',
          });
        }
      } catch (error) {
        console.log(error);
        setError('Une erreur est survenue lors du calcul')
      }
    }
    console.log("Value is operator", isOperator(value))
    if (!isOperator(value)) {
      setState(prev => ({
        ...prev,
        display: prev.display + value,
        error: null,
      }));
    }
    if (isOperator(value)) {

      setState(prev => ({
        currentNumber: prev.display + value,
        display: prev.display + value,
      }));

    }

  }
  const handleClear = () => {
    setState(initialState);
  };

  const handleBackspace = () => {
    setState(prev => ({
      ...prev,
      display: prev.display.slice(0, -1),
    }));
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-100 to-blue-900 flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl shadow-2xl w-full max-w-md overflow-hidden">
        {/* Header */}
        <div className="bg-black p-4 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Calculator className="text-white" size={24} />
            <h1 className="text-xl font-bold text-white">Calculatrice NPI</h1>
          </div>
          <button
            onClick={handleClear}
            className="p-2 text-white hover:text-gray-300 transition-colors"
            title="Tout effacer"
          >
            <RotateCcw size={20} />
          </button>
        </div>

        {/* Main Display */}
        <div className="p-4 bg-gray-100">
          <div className="flex flex-col bg-white p-4 rounded-lg shadow-inner mb-4">
            {state.currentNumber && (
              <div className="text-right text-gray-500 text-sm mb-1">
                {state.currentNumber} { }
              </div>
            )}
            <div className="flex items-center justify-between">
              <input
                type="text"
                value={state.display}
                readOnly
                className="text-right text-2xl font-medium w-full bg-transparent outline-none"
                placeholder="0"
              />
              <button
                onClick={handleBackspace}
                className="text-gray-500 hover:text-gray-700 ml-2"
                title="Effacer"
              >
                <Delete size={20} />
              </button>
            </div>
          </div>

          {error && (
            <div className="mb-4 p-2 bg-red-100 border border-red-400 text-red-700 rounded text-sm">
              {error}
            </div>
          )}

          {/* Keypad */}
          <div className="grid grid-cols-4 gap-2">
            {buttons.map((row, rowIndex) => (
              <React.Fragment key={rowIndex}>
                {row.map((button) => (
                  <button
                    key={button}
                    onClick={() => handleButtonClick(button)}
                    className={`p-4 text-xl font-medium rounded-lg transition-all active:scale-95
                      ${button === '='
                        ? 'bg-indigo-600 text-white hover:bg-indigo-700'
                        : isOperator(button)
                          ? 'bg-indigo-100 text-indigo-600 hover:bg-indigo-200'
                          : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                      }`}
                  >
                    {button}
                  </button>
                ))}
              </React.Fragment>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;