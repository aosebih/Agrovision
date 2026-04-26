import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcryptjs';
import { User } from './user.entity';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';

@Injectable()
export class UsersService {
  constructor(@InjectRepository(User) private userRepo: Repository<User>) {}

  async create(dto: CreateUserDto): Promise<User> {
    const existing = await this.userRepo.findOne({ where: { email: dto.email } });
    if (existing) throw new ConflictException('Email already exists');
    const hashed = await bcrypt.hash(dto.password, 10);
    const user = this.userRepo.create({ ...dto, password: hashed });
    return this.userRepo.save(user);
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.userRepo.findOne({ where: { email } });
  }

  async findById(id: string): Promise<User | null> {
    return this.userRepo.findOne({ where: { id } });
  }

  async getProfile(id: string): Promise<User> {
    const user = await this.findById(id);
    if (!user) throw new NotFoundException('User not found');
    const { password, ...result } = user;
    return result as User;
  }

  async update(id: string, dto: UpdateUserDto): Promise<User> {
    const user = await this.findById(id);
    if (!user) throw new NotFoundException('User not found');
    if (dto.password) {
      const hashedPassword = await bcrypt.hash(dto.password, 10);
      Object.assign(user, { ...dto, password: hashedPassword });
    } else {
      Object.assign(user, dto);
    }
    return this.userRepo.save(user);
  }
}