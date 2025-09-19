#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Sep 17 22:34:19 2025

@author: roger
"""

import os
import sys
import time  # 新增：用于时间戳
from langchain_openai import ChatOpenAI
from langchain_groq import ChatGroq
from langchain_anthropic import ChatAnthropic
from langchain.schema import HumanMessage, SystemMessage
from langchain.prompts import ChatPromptTemplate
from langchain_deepseek import ChatDeepSeek

from langchain_core.messages import HumanMessage, SystemMessage, AIMessage  # 更新：用 langchain_core
from langchain.prompts import ChatPromptTemplate

# 配置 API Key（优先从环境变量读取）
openai_key = os.getenv("OPENAI_API_KEY")
groq_key = os.getenv("GROQ_API_KEY")
anthropic_key = os.getenv("ANTHROPIC_API_KEY")
anthropic_key = "sk-euRh77i1iVh72v356r5lXNrgY1WQ7a14xbBVeY53iJmO5nv8"
deepseek_key = os.getenv("DEEPSEEK_API_KEY")


# 模型配置：{平台: {模型名: LLM实例}}
models = {}

if openai_key:
    models["openai"] = {
        "gpt-4o-mini": ChatOpenAI(model="gpt-4o-mini", api_key=openai_key, temperature=0.7, streaming=True),
        "gpt-4o": ChatOpenAI(model="gpt-4o", api_key=openai_key, temperature=0.7, streaming=True)
    }

if groq_key:
    models["groq"] = {
        "llama3-8b": ChatGroq(model="llama3-8b-8192", api_key=groq_key, temperature=0.7, streaming=True),
        "mixtral-8x7b": ChatGroq(model="mixtral-8x7b-32768", api_key=groq_key, temperature=0.7, streaming=True)
    }

if anthropic_key:
    models["anthropic"] = {
        "claude-3-5-sonnet": ChatAnthropic(model="claude-3-5-sonnet-20240620", api_key=anthropic_key, temperature=0.7, streaming=True)
    }

if deepseek_key:
    models["deepseek"] = {
        "deepseek-chat": ChatDeepSeek(model="deepseek-chat", api_key=deepseek_key, temperature=0.7, streaming=True),
        "deepseek-coder": ChatDeepSeek(model="deepseek-coder", api_key=deepseek_key, temperature=0.7, streaming=True)
    }
def get_user_choice():
    # 第一步：选择平台
    print("\n可用平台：")
    platform_list = list(models.keys())
    for i, platform in enumerate(platform_list, 1):
        print(f"{i}: {platform}")
    print("0: 退出")
    
    while True:
        try:
            platform_choice = input("\n选择平台序号 (e.g., 1): ").strip()
            if platform_choice.lower() in ['quit', 'exit'] or platform_choice == '0':
                return None
            platform_idx = int(platform_choice) - 1
            if 0 <= platform_idx < len(platform_list):
                selected_platform = platform_list[platform_idx]
                break
            else:
                print("无效序号，请重试。")
        except ValueError:
            print("请输入数字序号。")
    
    # 第二步：选择该平台的模型
    model_dict = models[selected_platform]
    model_list = list(model_dict.keys())
    print(f"\n{selected_platform} 的可用模型：")
    for i, model in enumerate(model_list, 1):
        print(f"{i}: {model}")
    print("0: 退出")
    
    while True:
        try:
            model_choice = input("\n选择模型序号 (e.g., 1): ").strip()
            if model_choice.lower() in ['quit', 'exit'] or model_choice == '0':
                return None
            model_idx = int(model_choice) - 1
            if 0 <= model_idx < len(model_list):
                selected_model = model_list[model_idx]
                return model_dict[selected_model]  # 返回 LLM 实例
            else:
                print("无效序号，请重试。")
        except ValueError:
            print("请输入数字序号。")
            
# 更新：流式聊天函数（模拟 OpenAI 示例：记录时间、实时打印 chunk + 延迟）
def chat_with_ai_stream(llm, conversation_history, use_stream=True, verbose_time=False):
    prompt = ChatPromptTemplate.from_messages(conversation_history)
    chain = prompt | llm
    if use_stream:
        start_time = time.time()  # 记录开始时间
        sys.stdout.write("\nAI: ")
        sys.stdout.flush()
        full_response = ""
        for chunk in chain.stream({}):  # 迭代 stream，像示例中的 for event in response
            if hasattr(chunk, 'content') and chunk.content:
                event_time = time.time() - start_time  # 计算延迟，像示例
                chunk_text = chunk.content  # 提取文本，像 event['choices'][0]['text']
                full_response += chunk_text
                sys.stdout.write(chunk_text)  # 实时输出，像示例的 print(event_text)
                sys.stdout.flush()
                if verbose_time:  # 可选：打印详细时间戳，像示例
                    print(f"\nText received: {chunk_text} ({event_time:.2f} seconds after request)")
        sys.stdout.write("\n")  # 换行
        sys.stdout.flush()
        final_time = time.time() - start_time
        if verbose_time:
            print(f"Full response received {final_time:.2f} seconds after request")
            print(f"Full text received: {full_response}")
        return full_response
    else:
        # 非流式回退
        response = chain.invoke({})
        print(f"\nAI: {response.content}")
        return response.content

def main():
    print("欢迎使用本地 AI 聊天平台！（支持流式输出，模拟 OpenAI stream=True）")
    conversation_history = [SystemMessage(content="你是一个有帮助的助手。")]
    current_llm = None
    use_stream = True
    verbose_time = False  # 默认不打印详细时间戳（可通过命令开启）
    
    # 首次选择模型
    print("\n首次选择模型：")
    current_llm = get_user_choice()
    if current_llm is None:
        return
    
    print(f"当前模型：{getattr(current_llm, 'model', '已选择')} | 流式输出：开启 | 详细时间戳：关闭")
    
    while True:
        user_input = input("\n你: ").strip()
        if not user_input:
            continue
        
        if user_input.lower() == 'quit' or user_input.lower() == 'exit':
            break
        elif user_input.lower() == 'switch':
            print("\n切换模型：")
            current_llm = get_user_choice()
            if current_llm is None:
                continue
            print(f"已切换到：{getattr(current_llm, 'model', '新模型')} | 流式输出：{ '开启' if use_stream else '关闭' } | 详细时间戳：{ '开启' if verbose_time else '关闭' }")
            continue
        elif user_input.lower() == 'clear':
            conversation_history = [SystemMessage(content="你是一个有帮助的助手。")]
            print("对话历史已清空。")
            continue
        elif user_input.lower() == 'stream on':
            use_stream = True
            print("流式输出已开启。")
            continue
        elif user_input.lower() == 'stream off':
            use_stream = False
            print("流式输出已关闭。")
            continue
        elif user_input.lower() == 'verbose on':
            verbose_time = True
            print("详细时间戳已开启（每个 chunk + 总时间）。")
            continue
        elif user_input.lower() == 'verbose off':
            verbose_time = False
            print("详细时间戳已关闭。")
            continue
        
        # 添加用户消息到历史
        conversation_history.append(HumanMessage(content=user_input))
        
        # 获取 AI 回答（支持流式 + 可选时间戳）
        try:
            answer = chat_with_ai_stream(current_llm, conversation_history, use_stream, verbose_time)
            
            # 添加 AI 回复到历史
            conversation_history.append(AIMessage(content=answer))
            
        except Exception as e:
            print(f"错误: {e} - 检查 API Key 或网络。")
    
    print("再见！")

if __name__ == "__main__":
    main()
    