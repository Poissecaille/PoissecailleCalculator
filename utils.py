from sqlmodel import Session
from models.evaluation import Evaluation
from models.expression import Expression


def evaluate_rpn_expression(expression: str) -> float:
    """Evaluate a RPN(Reverse Polish Notation) expression."""
    stack = []
    operators = {"+", "-", "*", "/"}
    for char in expression.strip().split():
        if char in operators:
            if len(stack) < 2:
                raise ValueError("Not enough operands. Cannot evaluate expression.")
            b = stack.pop()
            a = stack.pop()

            if char == "+":
                stack.append(a + b)
            elif char == "-":
                stack.append(a - b)
            elif char == "*":
                stack.append(a * b)
            elif char == "/":
                if b == 0:
                    raise ZeroDivisionError("Division by zero")
                stack.append(a / b)
        else:
            try:
                stack.append(float(char))
            except ValueError:
                raise ValueError(f" : {char}")
    print("stack: ", stack)
    if len(stack) != 1:
        raise ValueError("Invalid expression. Cannot evaluate expression.")
    return stack[0]


expression = "3 4 + 2 * 7 /"
result = evaluate_rpn_expression(expression)
print(f"Résultat : {result}")


def save_expression(session: Session, expression: Expression) -> None:
    """Save an expression in the database."""
    session.add(expression)
    session.commit()
    session.refresh(expression)


def save_evaluation(
    session: Session, expression: Expression, evaluation: Evaluation
) -> None:
    """Save an expression related evaluation in the database."""
    evaluation = Evaluation(expressionId=expression.id, value=evaluation.value)
    session.add(evaluation)
    session.commit()
    session.refresh(evaluation)
