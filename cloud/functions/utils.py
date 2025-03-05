from sqlmodel import Session

from logger import logger
from database import Evaluation, Expression


def evaluate_rpn_expression(expression: str) -> float:
    """Evaluate a RPN(Reverse Polish Notation) expression."""
    stack = []
    operators = {"+", "-", "*", "/"}
    logger.debug(f"expression: {expression} ")
    for char in expression.strip().replace(" ", ""):
        if char in operators:
            if len(stack) < 2:
                raise ValueError("Not enough operands. Cannot evaluate expression.")
            b = stack.pop()
            a = stack.pop()
            logger.debug(f"a:{a} b:{b}")
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
    logger.debug(f"stack: {stack}")
    if len(stack) != 1:
        raise ValueError("Invalid expression. Cannot evaluate expression.")
    return stack[0]


def save_expression(session: Session, expression: Expression) -> None:
    """Save an expression in the database."""
    session.add(expression)
    session.commit()
    session.refresh(expression)


def save_evaluation(session: Session, evaluation: Evaluation) -> None:
    """Save an expression related evaluation in the database."""
    session.add(evaluation)
    session.commit()
    session.refresh(evaluation)
