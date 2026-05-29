// src/chat/chat.controller.ts
import { Controller, Post, Body } from '@nestjs/common';
import { ChatService } from './chat.service';
import { IsString, IsNotEmpty } from 'class-validator';

export class AskDto {
  @IsString()
  @IsNotEmpty()
  question: string;
}

@Controller('chat')
export class ChatController {
  constructor(private readonly chatService: ChatService) {}

  @Post('ask')
  ask(@Body() dto: AskDto) {
    return this.chatService.ask(dto.question);
  }
}
