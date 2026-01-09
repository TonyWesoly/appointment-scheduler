package com.github.TonyWesoly.appointment_scheduler.model;

import jakarta.persistence.*;

import java.time.DayOfWeek;
import java.time.LocalTime;

@Entity
@Table(name = "availability")
public class Availability {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    //TODO: Add foreign key

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private DayOfWeek dayOfWeek;
    @Column(nullable = false)
    private LocalTime startTime;
    @Column(nullable = false)
    private LocalTime endTIme;

    public Availability() {
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public DayOfWeek getDayOfWeek() {
        return dayOfWeek;
    }

    public void setDayOfWeek(DayOfWeek dayOfWeek) {
        this.dayOfWeek = dayOfWeek;
    }

    public LocalTime getStartTime() {
        return startTime;
    }

    public void setStartTime(LocalTime startTime) {
        this.startTime = startTime;
    }

    public LocalTime getEndTIme() {
        return endTIme;
    }

    public void setEndTIme(LocalTime endTIme) {
        this.endTIme = endTIme;
    }
}
