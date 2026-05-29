from collections.abc import Callable, Iterable
from typing import Any

from openai import OpenAI

from postprocess.models import AbstractGenerativeModel


class GPTModel(AbstractGenerativeModel):
    def __init__(self, id: str = "gpt-5.1", api_key: str | None = None):
        super().__init__(id)
        self.client = OpenAI(api_key=api_key)

    def generate_with_tools(
        self,
        messages: list[dict[str, Any]],
        tools: Iterable[Callable[..., Any]] = (),
        max_tool_loops: int = 5,
    ) -> str:
        # The postprocess pipeline currently calls this without tools.
        # Keep the no-tool path working, and fail loudly if tool use is requested.
        if tuple(tools):
            raise NotImplementedError(
                "Tool calling not yet implemented for GPTModel"
            )

        response = self.client.responses.create(
            model=self.id,
            input=messages,
        )

        return response.output_text
