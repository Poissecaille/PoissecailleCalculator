/* eslint-disable @typescript-eslint/no-unused-vars */
import React, { useState } from 'react';
import { Calculator, RotateCcw, Delete, Download } from 'lucide-react';
import { evaluateExpression, exportCalculationsCSV } from './api';
import { CalculatorState } from './utils/types';
import { isOperator } from './utils/functions';
// NOTE Store useless here we can keep the component state inside the component itself for a small project
// NOTE No need for nested component here
const initialState: CalculatorState = {
  currentNumber: '',
  previousNumber: '',
  previousResult: '',
};

const buttons = [
  ['7', '8', '9', '/'],
  ['4', '5', '6', '*'],
  ['1', '2', '3', '-'],
  ['0', '.', '=', '+'],
];

const App = () => {
  const [state, setState] = useState<CalculatorState>(initialState);
  const [error, setError] = useState<string | null>(null);
  const [isExporting, setIsExporting] = useState(false);


  const displayErrorWithTimeout = (message: string) => {
    setError(message);
    handleClear();
    setTimeout(() => {
      setError(null);
    }, 3000);
  };

  const handleButtonClick = async (value: string) => {
    if (value === '=' && state.currentNumber) {
      try {
        const response = await evaluateExpression(state.currentNumber);

        if (response.code > 201) {
          displayErrorWithTimeout('Une erreur est survenue lors du calcul veuillez revoir votre notation NPI');
          setState(({
            currentNumber: '',
            previousNumber: state.previousNumber,
            previousResult: state.previousResult,
          }));
        } else {
          setState({
            currentNumber: '',
            previousNumber: state.currentNumber,
            previousResult: response.data!.toString(),
          });
        }
      } catch (error) {
        displayErrorWithTimeout('Une erreur est survenue lors du calcul veuillez revoir votre notation NPI')
      }
    }
    else {
      setState(({
        currentNumber: state.currentNumber + value,
        previousNumber: state.previousNumber,
        previousResult: state.previousResult,
      }));
    }
  }
  const handleClear = () => {
    setState(initialState);
  };

  const handleBackspace = () => {
    setState(prev => {
      const newState = {
        ...prev,
        currentNumber: prev.currentNumber.slice(0, -1),
      };
      return newState;
    });
  };
  const handleExportCSV = async () => {
    try {
      setIsExporting(true);
      const blob = await exportCalculationsCSV();
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `calculations-${new Date().toISOString().split('T')[0]}.csv`;
      document.body.appendChild(a);
      a.click();
      window.URL.revokeObjectURL(url);
      document.body.removeChild(a);
    } catch (error) {
      setState(prev => ({
        ...prev,
        error: 'Erreur lors de l\'export CSV',
      }));
    } finally {
      setIsExporting(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-100 to-blue-900 flex items-center justify-center p-4">
      {/* {`currentNumber:${state.currentNumber} previousNumber:${state.previousNumber} previousResult:${state.previousResult}`} */}
      <div className="bg-white rounded-2xl shadow-2xl w-full max-w-md overflow-hidden">
        {/* Header */}
        <div className="bg-black p-4 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Calculator className="text-white" size={24} />
            <h1 className="text-xl font-bold text-white">Calculatrice NPI</h1>
          </div>
          <div className="flex items-center gap-2">

            <button
              onClick={handleExportCSV}
              disabled={isExporting}
              className={`p-2 text-white hover:text-gray-300 transition-colors relative ${isExporting ? 'opacity-50 cursor-not-allowed' : ''
                }`}
              title="Exporter l'historique (CSV)"
            >
              <Download size={20} className={isExporting ? 'animate-bounce' : ''} />
            </button>
            <button
              onClick={handleClear}
              className="p-2 text-white hover:text-gray-300 transition-colors"
              title="Tout effacer"
            >
              <RotateCcw size={20} />
            </button>
          </div>
        </div>

        {/* Main Display */}
        <div className="p-4 bg-gray-100">
          <div className="flex flex-col bg-white p-4 rounded-lg shadow-inner mb-4">
            {state.previousResult && (
              <div className="text-right text-gray-500 text-sm mb-1">
                {`${state.previousNumber} = ${state.previousResult}`}
              </div>
            )}
            <div className="flex items-center justify-between">
              <input
                type="text"
                value={state.currentNumber}
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
                        ? 'bg-blue-600 text-white hover:bg-blue-700'
                        : isOperator(button)
                          ? 'bg-blue-100 text-blue-600 hover:bg-blue-200'
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